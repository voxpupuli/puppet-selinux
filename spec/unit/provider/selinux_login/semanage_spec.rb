# frozen_string_literal: true

require 'spec_helper'

semanage_provider = Puppet::Type.type(:selinux_login).provider(:semanage)
login = Puppet::Type.type(:selinux_login)

login_helper_output = <<~EOS
  policy root unconfined_u s0-s0:c0.c1023
  policy __default__ unconfined_u s0-s0:c0.c1023
  policy localuser staff_u s0-s0:c0.c1023
  policy %localgroup unconfined_u s0-s0:c0.c1023
  policy %localgroup2 unconfined_u s0-s0:c0.c1023
  local __default__ user_u s0
  local localuser staff_u s0-s0:c0.c1023
  local %localgroup unconfined_u s0-s0:c0.c1023
  local %localgroup2 unconfined_u s0-s0:c0.c1023
EOS

instance_examples = {
  0 => {
    ensure: :present,
    name: 'root',
    selinux_login_name: 'root',
    selinux_mlsrange: 's0-s0:c0.c1023',
    selinux_user: 'unconfined_u',
    source: :policy,
    title: 'root',
  },
  1 => {
    ensure: :present,
    name: '__default__',
    selinux_login_name: '__default__',
    selinux_mlsrange: 's0',
    selinux_user: 'user_u',
    source: :local,
    title: '__default__',
  },
  2 => {
    ensure: :present,
    name: 'localuser',
    selinux_login_name: 'localuser',
    selinux_mlsrange: 's0-s0:c0.c1023',
    selinux_user: 'staff_u',
    source: :local,
    title: 'localuser',
  },
  3 => {
    ensure: :present,
    name: '%localgroup',
    selinux_login_name: '%localgroup',
    selinux_mlsrange: 's0-s0:c0.c1023',
    selinux_user: 'unconfined_u',
    source: :local,
    title: '%localgroup'
  },
  4 => {
    ensure: :present,
    name: '%localgroup2',
    selinux_login_name: '%localgroup2',
    selinux_mlsrange: 's0-s0:c0.c1023',
    selinux_user: 'unconfined_u',
    source: :local,
    title: '%localgroup2'
  },
}

# remove the source key as it's supposed to error out
resource_example = instance_examples[2].clone
resource_example.delete(:source)

describe semanage_provider do
  on_supported_os.each do |os, _facts|
    context "on #{os}" do
      context 'with some local login definitions' do
        before do
          # Call to python helper script
          allow(semanage_provider).to receive(:python).and_return(login_helper_output)
        end

        it 'returns 5 resources' do
          expect(described_class.instances.size).to eq(5)
        end

        instance_examples.each do |index, hash|
          it "parses example #{index} correctly" do
            expect(described_class.instances[index].instance_variable_get('@property_hash')).to eq(hash)
          end
        end
      end

      context 'creating' do
        let(:resource) do
          res = login.new(resource_example)
          res.provider = semanage_provider.new
          res
        end

        it 'runs semanage login -a' do
          expect(described_class).to receive(:semanage).with('login', '-a', '-s', 'staff_u', '-r', 's0-s0:c0.c1023', 'localuser')
          resource.provider.create
        end
      end

      context 'deleting' do
        let(:resource) do
          res = login.new(resource_example)
          res.provider = semanage_provider.new(resource_example)
          res
        end

        it 'runs semanage login -d' do
          expect(described_class).to receive(:semanage).with('login', '-d', 'localuser')
          resource.provider.destroy
        end
      end

      context 'with resources differing from the catalog' do
        let(:resources) do
          {
            'localuser2' => login.new(
              name: 'localuser2',
              selinux_login_name: 'localuser2',
              selinux_mlsrange: 's0',
              selinux_user: 'user_u',
              title: 'localuser2'
            ),
            'localuser' => login.new(resource_example)
          }
        end

        before do
          # prefetch:
          allow(semanage_provider).to receive(:python).and_return(login_helper_output)
          semanage_provider.prefetch(resources)
        end

        context 'prefetch finds the provider for localuser (resource example)' do
          let(:p) { resources['localuser'].provider }

          it { expect(p.name).to eq('localuser') }
          it { expect(p.selinux_login_name).to eq('localuser') }
          it { expect(p.selinux_mlsrange).to eq('s0-s0:c0.c1023') }
          it { expect(p.selinux_user).to eq('staff_u') }
        end

        context 'prefetch does not find a provider for nonexistant user' do
          it { expect(resources['localuser2'].provider).to be_nil }
        end
      end
    end
  end
end
