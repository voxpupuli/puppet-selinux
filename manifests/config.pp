# @summary Configure the system to use SELinux on the system.
#
# It is included in the main class `selinux`
#
# @param mode See main class
# @param type See main class
#
# @api private
#
class selinux::config (
  $mode,
  $type,
) {
  assert_private()

  if ($mode == 'enforcing' and !$facts['os']['selinux']['enabled']) {
    # lint:ignore:140chars
    notice('SELinux is disabled. Forcing configuration to permissive to avoid problems. To disable this warning, explicitly set selinux::mode to permissive or disabled.')
    # lint:endignore
    $_real_mode = 'permissive'
  } else {
    $_real_mode = $mode
  }

  if $_real_mode {
    if $facts['os']['family'] == 'Debian' and !$facts['os']['selinux']['enabled'] {
      # Debian-based OSes also need to change the kernel boot parameters in the
      # appropriate version of GRUB.
      # See: https://wiki.debian.org/SELinux/Setup.
      exec { 'activate-selinux':
        command  => '/usr/sbin/selinux-activate',
        unless   => shell_join(['/usr/bin/grep', '-q', '^GRUB_CMDLINE_LINUX=.*security=selinux', '/etc/default/grub']),
        provider => 'shell',
      }
    }

    file_line { "set-selinux-config-to-${_real_mode}":
      path  => '/etc/selinux/config',
      line  => "SELINUX=${_real_mode}",
      match => '^SELINUX=\w+',
    }

    case $_real_mode {
      'permissive', 'disabled': {
        $sestatus = 'permissive'
        if $_real_mode == 'disabled' and $facts['os']['selinux']['current_mode'] == 'permissive' {
          notice('A reboot is required to fully disable SELinux. SELinux will operate in Permissive mode until a reboot')
        }
      }
      'enforcing': {
        $sestatus = 'enforcing'
      }
      default : {
        fail('You must specify a mode (enforced, permissive, or disabled) for selinux operation')
      }
    }

    # a complete relabeling is required when switching from disabled to
    # permissive or enforcing. Ensure the autorelabel trigger file is created.
    if $_real_mode in ['enforcing','permissive'] and !$facts['os']['selinux']['enabled'] {
      file { '/.autorelabel':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        # The contents of the file are interpreted on most OSes (at least EL7
        # and Debian 10) as extra options for fixfiles. Anything else causes an
        # argument error and a failure to relabel.
        content => '',
      }
    }

    exec { "change-selinux-status-to-${_real_mode}":
      command => "setenforce ${sestatus}",
      unless  => "getenforce | grep -Eqi '${sestatus}|disabled'",
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    }
  }

  if $type {
    file_line { "set-selinux-config-type-to-${type}":
      path  => '/etc/selinux/config',
      line  => "SELINUXTYPE=${type}",
      match => '^SELINUXTYPE=\w+',
    }
  }
}
