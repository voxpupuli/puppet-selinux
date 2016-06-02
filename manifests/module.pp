# Definition: selinux::module
#
# Description
#  This class will either install or uninstall a SELinux module from a running system.
#  This module allows an admin to keep .te files in text form in a repository, while
#  allowing the system to compile and manage SELinux modules.
#
#  Concepts incorporated from:
#  http://stuckinadoloop.wordpress.com/2011/06/15/puppet-managed-deployment-of-selinux-modules/
#
# Parameters:
#   - $ensure: (present|absent) - sets the state for a module
#   - $sx_mod_dir (absolute_path) - sets the operating state for SELinux.
#   - $source: the source file (either a puppet URI or local file) of the SELinux .te module
#   - $makefile: the makefile file path
#   - $prefix: the prefix to add to the loaded module. Defaults to 'local_'.
#
# Actions:
#  Compiles a module using make and installs it
#
# Requires:
#  - SELinux
#
# Sample Usage:
#  selinux::module{ 'apache':
#    ensure => 'present',
#    source => 'puppet:///modules/selinux/apache.te',
#  }
#
define selinux::module(
  $source       = undef,
  $content      = undef,
  $ensure       = 'present',
  $makefile     = '/usr/share/selinux/devel/Makefile',
  $prefix       = 'local_',
  $sx_mod_dir   = '/usr/share/selinux',
  $syncversion  = true,
) {

  require selinux

  validate_re($ensure, [ '^present$', '^absent$' ], '$ensure must be "present" or "absent"')
  if $ensure == 'present' and $source == undef and $content == undef {
    fail("You must provide 'source' or 'content' field for selinux module")
  }
  if $source != undef {
    validate_string($source)
  }
  if $content != undef {
    validate_string($content)
  }
  validate_string($prefix)
  validate_absolute_path($sx_mod_dir)
  validate_absolute_path($makefile)
  validate_bool($syncversion)

  $selinux_policy = $::selinux_config_policy ? {
    /targeted|strict/ => $::selinux_config_policy,
    default           => $::selinux_custom_policy,
  }

  ## Begin Configuration
  file { "${sx_mod_dir}/${prefix}${name}.te":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $source,
    content => $content,
  }
  ~>
  exec { "${sx_mod_dir}/${prefix}${name}.pp":
  # Only allow refresh in the event that the initial .te file is updated.
    path        => '/sbin:/usr/sbin:/bin:/usr/bin',
    refreshonly => true,
    cwd         => $sx_mod_dir,
    command     => "make -f ${makefile} ${prefix}${name}.pp",
  }
  ->
  selmodule { $name:
    # Load the module if it has changed or was not loaded
    # Warning: change the .te version!
    ensure        => $ensure,
    selmodulepath => "${sx_mod_dir}/${prefix}${name}.pp",
    syncversion   => $syncversion,
  }
}
