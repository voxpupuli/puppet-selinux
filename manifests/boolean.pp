# Defined type: selinux::boolean
#
# This class will set the state of an SELinux boolean.
# All pending values are written to the policy file on disk, so they will be persistant across reboots.
# Ensure that the manifest notifies a related service as a restart for that service may be required.
#
# @example activate boolean
#   selinux::boolean{ 'named_write_master_zones':
#      ensure     => 'on',
#   }
#
# @example disable boolean
#   selinux::boolean{ 'named_write_master_zones':
#      ensure     => 'off',
#   }
#
# @param ensure Sets the current state of a particular SELinux boolean. Valid values: on, off
# @param persistent Should a particular SELinux boolean persist across reboots
#
define selinux::boolean (
  $ensure     = 'on',
  $persistent = true,
) {

  include ::selinux

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

  # seboolean calls getsebool and setsebool 
  # they only work when current mode is not disabled.
  if $::selinux {
    selboolean { $name:
      value      => $value,
      persistent => $persistent,
    }
  }
}
