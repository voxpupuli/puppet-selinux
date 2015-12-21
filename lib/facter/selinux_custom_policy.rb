# As a workaround for Facter bug with EL7:
# https://tickets.puppetlabs.com/browse/FACT-756
#

require 'facter'

Facter.add(:selinux_custom_policy) do
  confine :kernel => 'Linux', :osfamily => 'RedHat', :operatingsystemmajrelease => '7', :selinux => ['true', true]
  setcode do
    Facter::Util::Resolution.exec("sestatus | grep 'Loaded policy name' | awk '{ print \$4 }'")
  end
end
