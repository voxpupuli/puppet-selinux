# As a workaround for Facter bug with EL7:
# https://tickets.puppetlabs.com/browse/FACT-756
#

require 'facter'

Facter.add(:selinux_custom_policy) do
  confine kernel: 'Linux', osfamily: 'RedHat', operatingsystemmajrelease: '7', selinux: ['true', true]
  setcode do
    policy = nil
    output = Facter::Util::Resolution.exec('sestatus 2>/dev/null')
    if output
      output.each_line do |line|
        break if line =~ %r{^Loaded policy name:\s*(?<policy>.*)$}
      end
    end
    policy
  end
end
