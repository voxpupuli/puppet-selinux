# Definition: selinux::restorecon
#
# Description
#  This method provides the restorecon, applies the new security context to the files.
#
# Parameters:
#   - $pathname: folder path to file context needs to be applied after semanage.
#
# Actions:
#  Runs "restorecon" with options to persistently set the file context
#
# Requires:
#  - SELinux
#  - policycoreutils-python (for el-based systems)
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
