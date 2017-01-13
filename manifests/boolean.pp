# selinux::boolean
#
# This class will set the state of an SELinux boolean.
#
# @example Enable `named_write_master_zones`  boolean
#   selinux::boolean{ 'named_write_master_zones':
#      ensure     => "on",
#   }
#
# @example Ensure `named_write_master_zones` boolean is disabled
#   selinux::boolean{ 'named_write_master_zones':
#      ensure     => "off",
#   }
#
# @param ensure Set to on or off
# @param persistent Set to false if you don't want it to survive a reboot.
#
define selinux::boolean (
  $ensure     = 'on',
  $persistent = true,
) {

  include ::selinux

  Anchor['selinux::module post'] ->
  Selinux::Boolean[$title] ->
  Anchor['selinux::end']

  $ensure_real = $ensure ? {
    true    => 'true', # lint:ignore:quoted_booleans
    false   => 'false', # lint:ignore:quoted_booleans
    default => $ensure,
  }

  validate_re($ensure_real, ['^on$', '^true$', '^present$', '^off$', '^false$', '^absent$'], 'Valid ensures must be one of on, true, present, off, false, or absent')
  validate_bool($persistent)

  $value = $ensure_real ? {
    /(?i-mx:on|true|present)/  => 'on',
    /(?i-mx:off|false|absent)/ => 'off',
    default                    => undef,
  }

  selboolean { $name:
    value      => $value,
    persistent => $persistent,
  }
}
