selinux::fcontext{'set-mysql-log-context':
  seltype  => 'mysqld_log_t',
  pathspec => '/u01/log/mysql(/.*)?',
}
