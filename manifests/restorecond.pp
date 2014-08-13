#
# Class selinux::restorecond
#
class selinux::restorecond (
  $config_file                   = $selinux::params::restorecond_config_file,
  $config_file_mode              = $selinux::params::restorecond_config_file_mode,
  $config_file_owner             = $selinux::params::restorecond_config_file_owner,
  $config_file_group             = $selinux::params::restorecond_config_file_group,
  $sx_mod_dir                    = 'UNSET',
  $mode                          = 'UNSET',
  $restorecond_config_file       = 'UNSET',
  $restorecond_config_file_mode  = 'UNSET',
  $restorecond_config_file_owner = 'UNSET',
  $restorecond_config_file_group = 'UNSET',
) {
  include selinux::params

  $sx_mod_dir_real = $sx_mod_dir ? {
    'UNSET' => $::selinux::params::sx_mod_dir,
    default => $sx_mod_dir,
  }

  $mode_real = $mode ? {
    'UNSET' => $::selinux::params::mode,
    default => $mode,
  }

  $restorecond_config_file_real = $restorecond_config_file ? {
    'UNSET' => $::selinux::params::restorecond_config_file,
    default => $restorecond_config_file,
  }

  $restorecond_config_file_mode_real = $restorecond_config_file_mode ? {
    'UNSET' => $::selinux::params::restorecond_config_file_mode,
    default => $restorecond_config_file_mode,
  }

  $restorecond_config_file_owner_real = $restorecond_config_file_owner ? {
    'UNSET' => $::selinux::params::restorecond_config_file_owner,
    default => $restorecond_config_file_owner,
  }

  $restorecond_config_file_group_real = $restorecond_config_file_group ? {
    'UNSET' => $::selinux::params::restorecond_config_file_group,
    default => $restorecond_config_file_group,
  }

  class{'selinux::restorecond::install':} ->
  class{'selinux::restorecond::config':} ~>
  class{'selinux::restorecond::service':}
}
