# Class: selinux
#
# This class manages SELinux on RHEL based systems.
#
# @example Enable enforcing mode with targeted policy
#   class { 'selinux':
#     mode => 'enforcing',
#     type => 'targeted',
#   }
#
# @param mode sets the operating state for SELinux.
#   Default value: undef
#   Allowed values: (enforcing|permissive|disabled|undef)
# @param type sets the selinux type
#   Default value: undef
#   Allowed values: (targeted|minimum|mls|undef)
# @param refpolicy_makefile the path to the system's SELinux makefile for the refpolicy framework
#   Default value: /usr/share/selinux/devel/Makefile
#   Allowed value: absolute path
# @param manage_package manage the package for selinux tools and refpolicy
#   Default value: true
# @param package_name sets the name for the selinux tools package
#   Default value: OS dependent (see params.pp)
# @param refpolicy_package_name sets the name for the refpolicy development package, required for the
# refpolicy module builder
#   Default value: OS dependent (see params.pp)
# @param default_builder which builder to use by default with selinux::module
#   Default value: refpolicy
# @param boolean Hash of selinux::boolean resource parameters
# @param fcontext Hash of selinux::fcontext resource parameters
# @param module Hash of selinux::module resource parameters
# @param permissive Hash of selinux::module resource parameters
# @param port Hash of selinux::port resource parameters
#
class selinux (
  $mode                   = $::selinux::params::mode,
  $type                   = $::selinux::params::type,
  $refpolicy_makefile     = $::selinux::params::refpolicy_makefile,
  $manage_package         = $::selinux::params::manage_package,
  $package_name           = $::selinux::params::package_name,
  $refpolicy_package_name = $::selinux::params::refpolicy_package_name,
  $module_build_root      = $::selinux::params::module_build_root,
  $default_builder        = 'simple',

  ### START Hiera Lookups ###
  $boolean        = undef,
  $fcontext       = undef,
  $module         = undef,
  $permissive     = undef,
  $port           = undef,
  ### END Hiera Lookups ###

) inherits selinux::params {

  $mode_real = $mode ? {
    /\w+/   => $mode,
    default => 'undef',
  }

  $type_real = $type ? {
    /\w+/   => $type,
    default => 'undef',
  }

  validate_re($mode_real, ['^enforcing$', '^permissive$', '^disabled$', '^undef$'], "Valid modes are enforcing, permissive, and disabled.  Received: ${mode}")
  validate_re($type_real, ['^targeted$', '^minimum$', '^mls$', '^undef$'], "Valid types are targeted, minimum, and mls.  Received: ${type}")
  validate_string($refpolicy_makefile)
  validate_bool($manage_package)
  validate_string($package_name)

  class { '::selinux::package':
    manage_package => $manage_package,
    package_name   => $package_name,
  }

  class { '::selinux::config': }

  if $boolean {
    create_resources ( 'selinux::boolean', hiera_hash('selinux::boolean', $boolean) )
  }
  if $fcontext {
    create_resources ( 'selinux::fcontext', hiera_hash('selinux::fcontext', $fcontext) )
  }
  if $module {
    create_resources ( 'selinux::module', hiera_hash('selinux::module', $module) )
  }
  if $permissive {
    create_resources ( 'selinux::permissive', hiera_hash('selinux::permissive', $permissive) )
  }
  if $port {
    create_resources ( 'selinux::port', hiera_hash('selinux::port', $port) )
  }

  # Ordering
  anchor { 'selinux::start': } ->
  Class['selinux::package'] ->
  Class['selinux::config'] ->
  anchor { 'selinux::module pre': } ->
  anchor { 'selinux::module post': } ->
  anchor { 'selinux::end': }
}
