# This method will manage a selinux login, and will
# persist it across reboots.
#
# @summary Manage a SELinux login
#
# @example Add a map for the localuser to staff_u
#   selinux::login { 'localuser_staff_u':
#     ensure   => 'present',
#     selinux_login_name  => 'localuser',
#     selinux_user => 'staff_u',
#   }
#
# @param ensure Set to present to add or absent to remove a selinux login.
# @param selinux_login_name A Linux user or group
# @param selinux_user The selinux user to map to
#
define selinux::login (
  String[1]                    $selinux_login_name,
  String[1]                    $selinux_user,
  Enum['present', 'absent'] $ensure = 'present',
) {
  include selinux

  if $ensure == 'present' {
    Anchor['selinux::module post']
    -> Selinux::Login[$title]
    -> Anchor['selinux::end']
  } elsif $ensure == 'absent' {
    Class['selinux::config']
    -> Selinux::Login[$title]
    -> Anchor['selinux::module pre']
  } else {
    fail('Unexpected $ensure value')
  }

  # Do nothing unless SELinux is enabled
  if $facts['os']['selinux']['enabled'] {
    selinux_login { $selinux_login_name:
      ensure             => $ensure,
      selinux_login_name => $selinux_login_name,
      selinux_user       => $selinux_user,
    }
  }
}
