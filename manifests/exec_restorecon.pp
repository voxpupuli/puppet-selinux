# selinux::exec_restorecon
# 
# A convenience wrapper around a restorecon exec
#
# Will execute after all other SELinux changes have been applied, but before
# Anchor['selinux::end']
# 
# @param path The path to run restorecon on. Defaults to resource title.
# @param recurse Whether restorecon should recurse. Defaults to true
# @param refreshonly see the Exec resource
# @param unless see the Exec resource
# @param onlyif see the Exec resource
#
define selinux::exec_restorecon(
  Stdlib::Absolutepath $path        = $title,
  Boolean              $refreshonly = true,
  Boolean              $recurse     = true,
  Optional[String]     $unless      = undef,
  Optional[String]     $onlyif      = undef,
) {
  include ::selinux
  $command = $recurse ? {
    true  => 'restorecon -R',
    false => 'restorecon',
  }

  exec {"selinux::exec_restorecon ${path}":
    path        => '/sbin:/usr/sbin',
    command     => sprintf('%s %s', $command, shellquote($path)),
    refreshonly => $refreshonly,
    unless      => $unless,
    onlyif      => $onlyif,
    before      => Anchor['selinux::end'],
  }

  Anchor['selinux::module post']  -> Exec["selinux::exec_restorecon ${path}"]
}
