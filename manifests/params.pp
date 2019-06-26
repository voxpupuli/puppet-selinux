# This class provides default parameters for the selinux class
#
# @api private
#
class selinux::params {
  $module_build_root = "${facts['puppet_vardir']}/puppet-selinux"

  case $facts['os']['name'] {
    'Amazon': {
      $package_name = 'policycoreutils'
    }

    'CentOS', 'RedHat': {
      $package_name = $facts['os']['release']['major'] ? {
        '5'     => 'policycoreutils',
        '6'     => 'policycoreutils-python',
        '7'     => 'policycoreutils-python',
        default => 'policycoreutils-python-utils',
      }
    }

    'Fedora': {
      $sx_fs_mount = '/sys/fs/selinux'
      $package_name = $facts['os']['release']['major'] ? {
        /19|20/  => 'policycoreutils-python',
        /2[1-3]/ => 'policycoreutils-devel',
        default  => 'policycoreutils-python-utils',
      }
    }

    default: {
      fail("${facts['os']['name']} is not supported by ${name}")
    }
  }
}
