# Class:
#
# Description
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

selinux::module { 'apache':
  ensure    => 'present',
  source_te => 'puppet:///modules/selinux/apache.te',
  builder   => 'simple',
}
