require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

def policy_package_for(hosts)
  case hosts[0]['platform']
  when %r{^debian}
    'selinux-policy-default'
  else
    'selinux-policy-targeted'
  end
end

def have_selinux_ruby_library(hosts)
  hosts[0]['platform'] !~ %r{^debian}
end

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    install_module
    install_module_dependencies

    # Relabelling fails because systemd tries to connect the script's STDIN to
    # a serial port that doesn't exist (in Vagrant, at least). Work around like
    # in https://bugs.centos.org/view.php?id=13213
    hosts.each do |host|
      next unless host['platform'] =~ %r{^el-7}

      on host, 'sed -i -e "s/console=tty0 console=ttyS0,115200/console=tty0/" /etc/default/grub'
      on host, 'cat /etc/default/grub'
      on host, 'grub2-mkconfig -o /boot/grub2/grub.cfg'
    end
  end

  unless have_selinux_ruby_library(hosts)
    c.filter_run_excluding requires_selinux_ruby_library: true
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
