# Groups
selinux::login { '%localgroup_staff_u':
  ensure             => 'present',
  selinux_login_name => '%localgroup',
  selinux_user       => 'staff_u',
}

selinux::login { '%localgroup2_staff_u_mls':
  ensure             => 'present',
  selinux_login_name => '%localgroup2',
  selinux_user       => 'staff_u',
  selinux_mlsrange   => 's0-s0:c0.c1023',
}

# Individual
selinux::login { 'localuser_staff_u':
  ensure             => 'present',
  selinux_login_name => 'localuser',
  selinux_user       => 'staff_u',
}

selinux::login { 'localuser2_staff_u_mls':
  ensure             => 'present',
  selinux_login_name => 'localuser2',
  selinux_user       => 'staff_u',
  selinux_mlsrange   => 's0-s0:c0.c1023',
}
