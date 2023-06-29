# frozen_string_literal: true

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
