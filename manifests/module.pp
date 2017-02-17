# Defined type: selinux::module
#
# This class will either install or uninstall a SELinux module from a running system.
# This module allows an admin to keep .te files in text form in a repository, while
# allowing the system to compile and manage SELinux modules.
#
# Concepts incorporated from:
# http://stuckinadoloop.wordpress.com/2011/06/15/puppet-managed-deployment-of-selinux-modules/
# 
# @example compile and load the apache module - does not require make or the policy
#   devel package
#   selinux::module{ 'apache':
#     ensure    => 'present',
#     source_te => 'puppet:///modules/selinux/apache.te',
#     builder   => 'simple'
#   }
#
# @example compile a module the refpolicy way. It will install the policy devel and
#   dependent packages like make.
#   selinux::module{ 'mymodule':
#     ensure    => 'present',
#     source_te => 'puppet:///modules/profile/selinux/mymodule.te',
#     source_fc => 'puppet:///modules/profile/selinux/mymodule.fc',
#     source_if => 'puppet:///modules/profile/selinux/mymodule.if',
#     builder   => 'simple'
#   }
#
# @param ensure present or absent
# @param source_te the source file (either a puppet URI or local file) of the SELinux .te file
# @param source_fc the source file (either a puppet URI or local file) of the SELinux .fc file
# @param source_if the source file (either a puppet URI or local file) of the SELinux .if file
# @param builder either 'simple' or 'refpolicy'. The simple builder attempts to use checkmodule
#   to build the module, whereas 'refpolicy' uses the refpolicy framework, but requires 'make'
define selinux::module(
  Optional[String] $source_te = undef,
  Optional[String] $source_fc = undef,
  Optional[String] $source_if = undef,
  Enum['absent', 'present'] $ensure = 'present',
  Optional[Enum['simple', 'refpolicy']] $builder = undef,
) {
  include ::selinux

  if $builder == 'refpolicy' {
    require ::selinux::refpolicy_package
  }

  if ($builder == 'simple' and $source_if != undef) {
    fail("The simple builder does not support the 'source_if' parameter")
  }

  # let's just make doubly sure that this is an absolute path:
  validate_absolute_path($::selinux::config::module_build_dir)
  validate_absolute_path($::selinux::refpolicy_makefile)

  $module_dir = $::selinux::config::module_build_dir
  $module_file = "${module_dir}/${title}"

  $build_command = pick($builder, $::selinux::default_builder, 'none') ? {
      'simple'    => shellquote("${::selinux::module_build_root}/bin/selinux_build_module_simple.sh", $title, $module_dir),
      'refpolicy' => shellquote('make', '-f', $::selinux::refpolicy_makefile, "${title}.pp"),
      'none'      => fail('No builder or default builder specified')
  }

  Anchor['selinux::module pre'] ->
  Selinux::Module[$title] ->
  Anchor['selinux::module post']
  $has_source = (pick($source_te, $source_fc, $source_if, false) != false)

  if $has_source and $ensure == 'present' {
    file {"${module_file}.te":
      ensure => 'file',
      source => $source_te,
      notify => Exec["clean-module-${title}"],
    }

    $content_fc = $source_fc ? { undef => '', default => undef }
    file {"${module_file}.fc":
      ensure  => 'file',
      source  => $source_fc,
      content => $content_fc,
      notify  => Exec["clean-module-${title}"],
    }

    $content_if = $source_if ? { undef => '', default => undef }
    file {"${module_file}.if":
      ensure  => 'file',
      source  => $source_if,
      content => $content_if,
      notify  => Exec["clean-module-${title}"],
    }
    # ensure it doesn't get purged if it exists
    file {"${module_file}.pp": selinux_ignore_defaults => true }

    exec { "clean-module-${title}":
      path        => '/bin:/usr/bin',
      cwd         => $module_dir,
      command     => "rm -f '${module_file}.pp' '${module_file}.loaded'",
      refreshonly => true,
      notify      => Exec["build-module-${title}"],
    }

    exec { "build-module-${title}":
      path    => '/bin:/usr/bin',
      cwd     => $module_dir,
      command => "${build_command} || (rm -f ${module_file}.pp ${module_file}.loaded && exit 1)",
      creates => "${module_file}.pp",
      notify  => Exec["install-module-${title}"],
    }
    # we need to install the module manually because selmodule is kind of dumb. It ends up
    # working fine, though.
    exec { "install-module-${title}":
      path    => '/sbin:/usr/sbin:/bin:/usr/bin',
      cwd     => $module_dir,
      command => "semodule -i ${module_file}.pp && touch ${module_file}.loaded",
      creates => "${module_file}.loaded",
      before  => Selmodule[$title],
    }

    # ensure it doesn't get purged if it exists
    file { "${module_file}.loaded": }
  }
  $module_path = $has_source ? {
    true  => "${module_file}.pp",
    false => undef
  }

  selmodule { $title:
    ensure        => $ensure,
    selmodulepath => $module_path,
  }
}
