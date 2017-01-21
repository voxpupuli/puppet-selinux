require 'spec_helper'

semanage_provider = Puppet::Type.type(:selinux_fcontext).provider(:semanage)
fcontext = Puppet::Type.type(:selinux_fcontext)

file_types = {
  'all files' => 'a',
  'directory' => 'd',
  'character device' => 'c',
  'block device' => 'b',
  'symbolic link' => 'l',
  'named pipe' => 'p',
  'regular file' => 'f',
  'socket' => 's'
}

semanage_output_template = <<-EOS
SELinux fcontext                                   type               Context

/foobar                                            THETYPE            system_u:object_r:bin_t:s0
/something/else                                    THETYPE            <<None>>

SELinux Local fcontext Equivalence

/foobar = /var/lib/whatever
EOS

describe semanage_provider do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      file_types.each do |name, ft|
        context "with a single #{name} fcontext" do
          before do
            semanage_output = semanage_output_template.gsub('THETYPE', name)
            described_class.expects(:semanage).with('fcontext', '--list', '-C').returns(semanage_output)
          end
          it 'returns two resources' do
            expect(described_class.instances.size).to eq(2)
          end
          it 'regular contexts get parsed properly' do
            expect(described_class.instances[0].instance_variable_get('@property_hash')).to eq(
              ensure: :present,
              name: "/foobar_#{ft}",
              pathspec: '/foobar',
              file_type: ft,
              seltype: 'bin_t',
              selrole: 'object_r',
              seluser: 'system_u',
              selrange: 's0'
            )
          end
          it '<<None>> contexts get parsed properly' do
            expect(described_class.instances[1].instance_variable_get('@property_hash')).to eq(
              ensure: :present,
              name: "/something/else_#{ft}",
              pathspec: '/something/else',
              file_type: ft,
              seltype: '<<none>>',
              selrole: nil,
              seluser: nil,
              selrange: nil
            )
          end
        end
      end
      context 'Creating with just seltype defined' do
        let(:resource) do
          res = fcontext.new(name: '/something(/.*)_a', file_type: 'a', seltype: 'some_type_t', ensure: :present, pathspec: '/something(/.*)')
          res.provider = semanage_provider.new
          res
        end
        it 'runs semanage fcontext -a ' do
          described_class.expects(:semanage).with('fcontext', '-a', '-t', 'some_type_t', '-f', 'a', '/something(/.*)')
          resource.provider.create
        end
      end
      context 'Deleting with just seltype defined' do
        let(:provider) do
          semanage_provider.new(name: '/something(/.*)_a', file_type: 'a', seltype: 'some_type_t', ensure: :present, pathspec: '/something(/.*)')
        end
        it 'runs semanage fcontext -d ' do
          described_class.expects(:semanage).with('fcontext', '-d', '-t', 'some_type_t', '-f', 'a', '/something(/.*)')
          provider.destroy
        end
      end
      context 'With resources differing from the catalog' do
        let(:resources) do
          return { '/var/lib/mydir_s' => fcontext.new(
            name: '/var/lib/mydir_s',
            pathspec: '/var/lib/mydir',
            file_type: 's',
            seltype: 'some_type_t'
          ),
                   '/foobar_f' => fcontext.new(
                     name: '/foobar_f',
                     file_type: 'f',
                     pathspec: '/foobar',
                     seltype: 'mytype_t',
                     seluser: 'myuser_u'
                   ) }
        end
        before do
          # prefetch should find the provider parsed from this:
          semanage_output = semanage_output_template.gsub('THETYPE', 'regular file')
          described_class.expects(:semanage).with('fcontext', '--list', '-C').returns(semanage_output)
          semanage_provider.prefetch(resources)
        end
        it 'finds provider for /foobar' do
          p = resources['/foobar_f'].provider
          expect(p).not_to eq(nil)
        end
        context 'has the correct attributes' do
          let(:p) { resources['/foobar_f'].provider }
          it { expect(p.file_type).to eq('f') }
          it { expect(p.seltype).to eq('bin_t') }
          it { expect(p.selrole).to eq('object_r') }
          it { expect(p.seluser).to eq('system_u') }
        end
        it 'can change seltype' do
          p = resources['/foobar_f'].provider
          described_class.expects(:semanage).with('fcontext', '-m', '-t', 'new_type_t', '-f', 'f', '/foobar')
          p.seltype = 'new_type_t'
        end
        it 'can change seluser' do
          p = resources['/foobar_f'].provider
          described_class.expects(:semanage).with('fcontext', '-m', '-s', 'unconfined_u', '-t', 'bin_t', '-f', 'f', '/foobar')
          p.seluser = 'unconfined_u'
        end
      end
    end
  end
end
