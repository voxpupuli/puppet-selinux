# Class selinux::restorecond
#
# Manage restorecond daemon
#
# @param config_file Path to config file
# @param config_file_mode Mode used in file resource
# @param config_file_owner Owner of the config file
# @param config_file_group Group of the config file
#
class selinux::restorecond (
  $config_file       = $selinux::params::restorecond_config_file,
  $config_file_mode  = $selinux::params::restorecond_config_file_mode,
  $config_file_owner = $selinux::params::restorecond_config_file_owner,
  $config_file_group = $selinux::params::restorecond_config_file_group,
) inherits selinux::params {

  include ::selinux
  Class['selinux']
  -> class{'::selinux::restorecond::config':}
  ~> class{'::selinux::restorecond::service':}
}
