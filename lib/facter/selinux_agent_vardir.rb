require 'puppet'
Facter.add(:selinux_agent_vardir) do
  setcode do
    Puppet.settings['vardir']
  end
end
