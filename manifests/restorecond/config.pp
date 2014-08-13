#
# Class selinux::restorecond::config
#
class selinux::restorecond::config {

  concat { $selinux::restorecond::config_file:
    ensure => present,
    mode   => $selinux::restorecond::restorecond_config_file_mode_real,
    owner  => $selinux::restorecond::config_file_owner_real,
    group  => $selinux::restorecond::config_file_group_real,
    notify => Service['restorecond'],
  }

  concat::fragment {'restorecond_config_header':
    target  => $selinux::restorecond::config_file_real,
    content => "# File Managed by Puppet\n",
    order   => '01'
  }

  concat::fragment {'restorecond_config_default':
    target  => $selinux::restorecond::config_file_real,
    source  => 'puppet:///modules/selinux/restorecond.conf',
    order   => '05'
  }
}
