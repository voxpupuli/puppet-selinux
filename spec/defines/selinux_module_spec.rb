require 'spec_helper'

describe 'selinux::module' do
  let(:title) { 'mymodule' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:workdir) do
        '/var/lib/puppet/puppet-selinux/modules/mymodule'
      end

      context 'ordering' do
        let(:params) do
          {
            source_te: 'puppet:///modules/mymodule/selinux/mymodule.te'
          }
        end
        it { is_expected.to contain_selinux__module('mymodule').that_requires('Anchor[selinux::module pre]') }
        it { is_expected.to contain_selinux__module('mymodule').that_comes_before('Anchor[selinux::module post]') }
      end

      context 'present case with refpolicy' do
        let(:params) do
          {
            source_te: 'puppet:///modules/mymodule/selinux/mymodule.te',
            builder: 'refpolicy'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.te").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f 'mymodule.pp' loaded", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: 'make -f /usr/share/selinux/devel/Makefile mymodule.pp || (rm -f mymodule.pp loaded && exit 1)', creates: "#{workdir}/mymodule.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: 'semodule -i mymodule.pp && touch loaded', cwd: workdir, creates: "#{workdir}/loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: "#{workdir}/module.pp") }
      end

      context 'present case with refpolicy' do
        let(:params) do
          {
            source_if: 'puppet:///modules/mymodule/selinux/mymodule.if',
            source_fc: 'puppet:///modules/mymodule/selinux/mymodule.fc',
            builder: 'refpolicy'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.if").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.fc").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f 'mymodule.pp' loaded", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: 'make -f /usr/share/selinux/devel/Makefile mymodule.pp || (rm -f mymodule.pp loaded && exit 1)', creates: "#{workdir}/mymodule.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: 'semodule -i mymodule.pp && touch loaded', cwd: workdir, creates: "#{workdir}/loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: "#{workdir}/module.pp") }
      end

      context 'present case with refpolicy' do
        let(:params) do
          {
            source_te: 'puppet:///modules/mymodule/selinux/mymodule.te',
            source_if: 'puppet:///modules/mymodule/selinux/mymodule.if',
            source_fc: 'puppet:///modules/mymodule/selinux/mymodule.fc',
            builder: 'refpolicy'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.te").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.if").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_file("#{workdir}/mymodule.fc").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f 'mymodule.pp' loaded", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: 'make -f /usr/share/selinux/devel/Makefile mymodule.pp || (rm -f mymodule.pp loaded && exit 1)', creates: "#{workdir}/mymodule.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: 'semodule -i mymodule.pp && touch loaded', cwd: workdir, creates: "#{workdir}/loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: "#{workdir}/module.pp") }
      end

      context 'present case with simple builder' do
        let(:params) do
          {
            source_te: 'puppet:///modules/mymodule/selinux/mymodule.te',
            builder: 'simple'
          }
        end

        it { is_expected.to contain_file(workdir) }
        it { is_expected.to contain_file("#{workdir}/mymodule.te").that_notifies('Exec[clean-module-mymodule]') }
        it { is_expected.to contain_exec('clean-module-mymodule').with(command: "rm -f 'mymodule.pp' loaded", cwd: workdir) }
        it { is_expected.to contain_exec('build-module-mymodule').with(command: '/var/lib/puppet/puppet-selinux/modules/selinux_build_module.sh mymodule || (rm -f mymodule.pp loaded && exit 1)', creates: "#{workdir}/mymodule.pp") }
        it { is_expected.to contain_exec('install-module-mymodule').with(command: 'semodule -i mymodule.pp && touch loaded', cwd: workdir, creates: "#{workdir}/loaded") }
        it { is_expected.to contain_selmodule('mymodule').with_ensure('present', selmodulepath: "#{workdir}/module.pp") }
      end

      context 'unsupported source with simple builder' do
        let(:params) do
          {
            source_if: 'puppet:///modules/mymodule/selinux/mymodule.te',
            builder: 'simple'
          }
        end

        it do
          is_expected.to raise_error(Puppet::Error, %r{simple builder does not support})
        end
      end
      context 'absent case' do
        let(:params) do
          {
            ensure: 'absent'
          }
        end

        it { is_expected.to contain_selmodule('mymodule').with_ensure('absent') }
        it { is_expected.not_to contain_file(workdir) }
      end
    end
  end
end
