# Class: selinux::restorecon
#
# Description
#  This class provides the restorecon, applies the new security context to the files.
#
# Sample Usage:
#  selinux::restorecon{'restore-apollo-log-context':
#     pathname => "/var/log/apollo/",
#  }

define selinux::restorecon (
  $pathname,
) {

  include selinux

  $resource_name = "add_restorecon_${pathname}"
  $command       = "restorecon -R -v \"${pathname}\""

  exec { $resource_name:
    command => $command,
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Class['selinux::package'],
  }
}
