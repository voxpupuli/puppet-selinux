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
  $mode = $::selinux::params::mode,

  ### START Hiera Lookups ###
  $selinux_booleans = {}
  $selinux_modules = {}
  $selinux_fcontexts = {}
  $selinux_ports = {}
  ### END Hiera Lookups ###
) inherits selinux::params {

  class { 'selinux::package': } ->
  class { 'selinux::config': }

  create_resources('selinux::boolean', $selinux_booleans)
  create_resources('selinux::module', $selinux_modules)
  create_resources('selinux::fcontext', $selinux_fcontexts)
  create_resources('selinux::port', $selinux_ports)
}
