# Class: selinux
#
# Description
#  This class manages SELinux on RHEL based systems.
#
# Parameters:
#  - $mode (enforcing|permissive|disabled) - sets the operating state for SELinux.
#
# Actions:
#  This module will configure SELinux and/or deploy SELinux based modules to running
#  system.
#
# Requires:
#  - Class[stdlib]. This is Puppet Labs standard library to include additional methods for use within Puppet. [https://github.com/puppetlabs/puppetlabs-stdlib]
#
# Sample Usage:
#  include selinux
#
class selinux (
  $mode           = $::selinux::params::mode,
  $type           = $::selinux::params::type,
  $manage_package = $::selinux::params::manage_package,
  $package_name   = $::selinux::params::package_name,
) inherits selinux::params {

  class { 'selinux::package':
    manage_package => $manage_package,
    package_name   => $package_name,
  } ->
  class { 'selinux::config': }
}
