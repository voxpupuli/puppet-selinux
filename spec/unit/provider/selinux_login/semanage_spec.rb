# frozen_string_literal: true

require 'spec_helper'

LOGIN_HELPER_OUTPUT = <<~EOS
  policy root unconfined_u
  policy __default__ unconfined_u
  policy localuser staff_u
  policy %localgroup unconfined_u
  policy %localgroup2 unconfined_u
  local __default__ user_u
  local localuser staff_u
  local %localgroup unconfined_u
  local %localgroup2 unconfined_u
EOS

INSTANCE_EXAMPLES = {
  0 => {
    ensure: :present,
    name: 'root',
    selinux_login_name: 'root',
    selinux_user: 'unconfined_u',
    source: :policy,
    title: 'root',
  },
  1 => {
    ensure: :present,
    name: '__default__',
    selinux_login_name: '__default__',
    selinux_user: 'user_u',
    source: :local,
    title: '__default__',
  },
  2 => {
    ensure: :present,
    name: 'localuser',
    selinux_login_name: 'localuser',
    selinux_user: 'staff_u',
    source: :local,
    title: 'localuser',
  },
  3 => {
    ensure: :present,
    name: '%localgroup',
    selinux_login_name: '%localgroup',
    selinux_user: 'unconfined_u',
    source: :local,
    title: '%localgroup',
  },
  4 => {
    ensure: :present,
    name: '%localgroup2',
    selinux_login_name: '%localgroup2',
    selinux_user: 'unconfined_u',
    source: :local,
    title: '%localgroup2',
  },
}.freeze

# remove the source key as it's supposed to error out
RESOURCE_EXAMPLE = INSTANCE_EXAMPLES[2].clone
RESOURCE_EXAMPLE.delete(:source)

LOGIN_TYPE = Puppet::Type.type(:selinux_login)

describe LOGIN_TYPE.provider(:semanage) do
  on_supported_os.each_key do |os|
    context "on #{os}" do
      context 'with some local login definitions' do
        before do
          # Call to python helper script
          allow(described_class).to receive(:python).and_return(LOGIN_HELPER_OUTPUT)
        end

        it 'returns 5 resources' do
          expect(described_class.instances.size).to eq(5)
        end

        INSTANCE_EXAMPLES.each do |index, hash|
          it "parses example #{index} correctly" do
            expect(described_class.instances[index].instance_variable_get('@property_hash')).to eq(hash)
          end
        end
      end

      context 'creating' do
        let(:resource) do
          res = LOGIN_TYPE.new(RESOURCE_EXAMPLE)
          res.provider = described_class.new
          res
        end

        it 'runs semanage login -a' do
          expect(described_class).to receive(:semanage).with('login', '-a', '-s', 'staff_u', 'localuser')
          resource.provider.create
        end
      end

      context 'deleting' do
        let(:resource) do
          res = LOGIN_TYPE.new(RESOURCE_EXAMPLE)
          res.provider = described_class.new(RESOURCE_EXAMPLE)
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
            'localuser2' => LOGIN_TYPE.new(
              name: 'localuser2',
              selinux_login_name: 'localuser2',
              selinux_user: 'user_u',
              title: 'localuser2',
            ),
            'localuser' => LOGIN_TYPE.new(RESOURCE_EXAMPLE),
          }
        end

        before do
          # prefetch:
          allow(described_class).to receive(:python).and_return(LOGIN_HELPER_OUTPUT)
          described_class.prefetch(resources)
        end

        context 'prefetch finds the provider for localuser (resource example)' do
          let(:p) { resources['localuser'].provider }

          it { expect(p.name).to eq('localuser') }
          it { expect(p.selinux_login_name).to eq('localuser') }
          it { expect(p.selinux_user).to eq('staff_u') }
        end

        context 'prefetch does not find a provider for nonexistant user' do
          it { expect(resources['localuser2'].provider).to be_nil }
        end
      end
    end
  end
end
