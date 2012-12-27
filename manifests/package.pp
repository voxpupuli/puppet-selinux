# Class: selinux::package
#
# This module manages additional packages required to support some of the functions.
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class selinux::package {
  case $::operatingsystem {
    centos,fedora,rhel,redhat,scientific: {
      package { 'policycoreutils-python':
        ensure => present,
      }
    }
    debian,ubuntu: {
    }
    opensuse,suse: {
    }
  }
}
