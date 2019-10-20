require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    install_module
    install_module_dependencies
  end
end

shared_examples 'a idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes' do
    apply_manifest(pp, catch_changes: true)
  end
end

def ensure_permissive_mode_on(hosts)
  hosts.each do |host|
    host.execute('getenforce') do |result|
      mode = result.stdout.strip
      if mode != 'Permissive'
        host.execute('sed -i "s/SELINUX=.*/SELINUX=permissive/" /etc/selinux/config')
        if mode == 'Disabled'
          host.reboot
        else
          host.execute('setenforce Permissive && test "$(getenforce)" = "Permissive"')
        end
      end
    end
  end
end
