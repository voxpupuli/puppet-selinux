# Groups
selinux::login { '%cn_cegbu_aconex_fr-dev-ops-priv_staff_u':
  ensure             => 'present',
  selinux_login_name => '%cn_cegbu_aconex_fr-dev-ops-priv',
  selinux_user       => 'staff_u',
}

# Individual
selinux::login { 'localuser_staff_u':
  ensure             => 'present',
  selinux_login_name => 'localuser',
  selinux_user       => 'staff_u',
}
