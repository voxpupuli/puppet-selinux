# Definition: selinux::fcontext
#
# Description
#  This class will manage a local file context setting, and will persist it across reboots.
#  It will perform a check to ensure the file context is not already set.
#
# Class created by Erik M Jacobs<erikmjacobs@gmail.com>
#  Adds to puppet-selinux by jfryman
#   https://github.com/jfryman/puppet-selinux
#  Originally written/sourced from Lance Dillon<>
#   http://riffraff169.wordpress.com/2012/03/09/add-file-contexts-with-puppet/
#
# Parameters:
#   - $context: A particular file context, like "mysqld_log_t"
#   - $pathname: An semanage fcontext-formatted pathname, like "/var/log/mysql(/.*)?"
#
# Actions:
#  Runs "semanage fcontext" with options to persistently set the file context
#
# Requires:
#  - SELinux
#  - policycoreutils-python (for el-based systems)
#
# Sample Usage:
#
# selinux::fcontext{'set-samba-rootfolder-context':
#   context => "mysqld_log_t",
#   pathname => "/var/log/mysql(/.*)?",
# }
#
define selinux::fcontext ( $context = "", $pathname = "", $policy = "targeted" ) {
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if ( $context == "" ) or ( $pathname == "" ) {
    fail("context and pathname must not be empty")
  }

  exec { "add_${context}_${pathname}":
    command => "semanage fcontext -a -t ${context} \"${pathname}\"",
    unless => "semanage fcontext -l|grep \"^${pathname}.*:${context}:\"",
  }
}
