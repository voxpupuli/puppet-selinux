selinux::fcontext::equivalence { '/opt/wordpress':
  ensure => 'present',
  target => '/usr/share/wordpress',
}
