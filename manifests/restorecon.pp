# Definition: selinux::restorecon
#
# Description
#  After running the restorecon, the file will have the correct context re-applied and the changes will be made permanent.
#
# Sample Usage:
#  selinux::restorecon{'restore-project-log-context':
#     pathname => "/var/log/project/",
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
