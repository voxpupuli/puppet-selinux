# This class provides default parameters for the selinux class
#
# @api private
#
class selinux::params {
  $module_build_root = "${facts['puppet_vardir']}/puppet-selinux"

  case $facts['osfamily'] {
    'RedHat': {
      if $facts['operatingsystem'] == 'Amazon' {
        $package_name = 'policycoreutils'
      } else {
        $package_name = $facts['operatingsystemmajrelease'] ? {
          '5'     => 'policycoreutils',
          '6'     => 'policycoreutils-python',
          '7'     => 'policycoreutils-python',
          default => 'policycoreutils-python-utils',
        }
      }
    }
    default: {
      fail("${::osfamily} is not supported")
    }
  }
}
