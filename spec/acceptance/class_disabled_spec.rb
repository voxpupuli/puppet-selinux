require 'spec_helper_acceptance'

describe 'selinux class - mode switching' do
  # To exercice autorelabelling.
  # The fcontext rules should be portable for this file
  test_file_path = '/var/test'
  test_file_type = 'var_t'

  # On Debian, SELinux is disabled by default. This first step brings it up to
  # par with EL and exercises the Debian-specific code.
  context 'when switching from unknown mode to permissive' do
    let(:pp) do
      <<-EOS
        class { 'selinux': mode => 'permissive' }
      EOS
    end

    context 'before reboot' do
      it_behaves_like 'a idempotent resource'

      describe package(policy_package_for(hosts)) do
        it { is_expected.to be_installed }
      end

      describe file('/etc/selinux/config') do
        its(:content) { is_expected.to match(%r{^SELINUX=permissive$}) }
      end
    end

    context 'after reboot' do
      before(:all) do
        hosts.each(&:reboot) if shell('getenforce').stdout.strip == 'Disabled'
      end

      it 'applies without changes' do
        apply_manifest(pp, catch_changes: true)
      end

      describe command('getenforce') do
        its(:stdout) { is_expected.to match(%r{^Permissive$}) }
      end
    end
  end

  context 'when switching from enforcing to disabled' do
    let(:pp) do
      <<-EOS
        class { 'selinux': mode => 'disabled' }
      EOS
    end

    context 'before reboot' do
      before(:all) do
        shell('sed -i "s/SELINUX=.*/SELINUX=enforcing/" /etc/selinux/config')
        shell('setenforce Enforcing && test "$(getenforce)" = "Enforcing"')
      end

      it_behaves_like 'a idempotent resource'

      describe file('/etc/selinux/config') do
        its(:content) { is_expected.to match(%r{^SELINUX=disabled$}) }
      end

      # Testing for Permissive brecause only after a reboot it's disabled
      describe command('getenforce') do
        its(:stdout) { is_expected.to match(%r{^Permissive$}) }
      end
    end

    context 'after reboot' do
      before(:all) do
        hosts.each(&:reboot)
      end

      it 'applies without changes' do
        apply_manifest(pp, catch_changes: true)
      end

      describe command('getenforce') do
        its(:stdout) { is_expected.to match(%r{^Disabled$}) }
      end
    end
  end

  context 'while disabled' do
    before(:all) do
      on(hosts, "touch #{test_file_path}")
    end

    describe file(test_file_path) do
      its(:selinux_label) { is_expected.to eq('?') }
    end
  end

  context 'when switching from disabled to permissive' do
    let(:pp) do
      <<-EOS
        class { 'selinux': mode => 'permissive' }
      EOS
    end

    context 'before reboot' do
      it_behaves_like 'a idempotent resource'

      describe file('/etc/selinux/config') do
        its(:content) { is_expected.to match(%r{^SELINUX=permissive$}) }
      end

      # Testing for Permissive brecause only after a reboot it's disabled
      describe command('getenforce') do
        its(:stdout) { is_expected.to match(%r{^Disabled$}) }
      end
    end

    context 'after reboot' do
      before(:all) do
        hosts.each(&:reboot)
      end

      it 'applies without changes' do
        apply_manifest(pp, catch_changes: true)
      end

      describe command('getenforce') do
        its(:stdout) { is_expected.to match(%r{^Permissive$}) }
      end

      describe file(test_file_path) do
        its(:selinux_label) { is_expected.to include(":#{test_file_type}:") }
      end
    end
  end
end
