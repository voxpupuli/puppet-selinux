require 'spec_helper_acceptance'

describe 'while disabled' do
  before(:all) do
    apply_manifest('class { "selinux": mode => "disabled" }', catch_failures: true)
    on(default, 'semanage boolean --noreload --deleteall')
    on(default, 'semodule --noreload --remove puppet_selinux_test_policy || true')
    on(default, 'semanage port --noreload --deleteall')
    hosts.each(&:reboot)
  end

  after(:all) do
    apply_manifest('class { "selinux": mode => "enforcing" }', catch_failures: true)
    on(default, 'semanage boolean --noreload --deleteall')
    on(default, 'semodule --noreload --remove puppet_selinux_test_policy || true')
    on(default, 'semanage port --noreload --deleteall')
    hosts.each(&:reboot)
  end

  describe command('getenforce') do
    its(:stdout) { is_expected.to match('Disabled') }
  end

  context 'selinux (main class)' do
    let(:pp) do
      <<-EOS
        class { 'selinux': mode => 'enforcing' }
      EOS
    end

    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'selinux::module' do
    let(:pp) do
      <<-EOS
      # with puppet4 I would use a HERE DOC to make this pretty,
      # but with puppet3 it's not possible.
      selinux::module { 'puppet_selinux_test_policy':
        content => "policy_module(puppet_selinux_test_policy, 1.0.0)\ngen_tunable(puppet_selinux_test_policy_bool, false)\ntype puppet_selinux_test_policy_t;\ntype puppet_selinux_test_policy_exec_t;\ninit_daemon_domain(puppet_selinux_test_policy_t, puppet_selinux_test_policy_exec_t)\ntype puppet_selinux_test_policy_port_t;\ncorenet_port(puppet_selinux_test_policy_port_t)\n",
        prefix => '',
        syncversion => undef,
      }
      EOS
    end

    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'selinux::boolean' do
    let(:pp) do
      <<-EOS
      selinux::boolean { 'puppet_selinux_test_policy_bool': }
      EOS
    end

    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'selinux::permissive' do
    let(:pp) do
      <<-EOS
      selinux::permissive { 'puppet_selinux_test_policy_t': context => 'puppet_selinux_test_policy_t', }
      EOS
    end

    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'selinux::port' do
    let(:pp) do
      <<-EOS
      selinux::port { 'puppet_selinux_test_policy_port_t/tcp':
        context => 'puppet_selinux_test_policy_port_t',
        port => '55555',
        protocol => 'tcp',
      }
      EOS
    end

    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
  end
end
