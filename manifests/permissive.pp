# selinux::permissive
#
# This method will set a context to permissive
#
# @param context A particular domain-context, like "oddjob_mkhomedir_t"
#
# @example Mark oddjob_mkhomedir_t permissive
#   selinux::permissive { 'allow-oddjob_mkhomedir_t':
#     context  => 'oddjob_mkhomedir_t',
#   }
#
define selinux::permissive (
  $context,
) {

  include ::selinux

  Anchor['selinux::module post'] ->
  Selinux::Permissive[$title] ->
  Anchor['selinux::end']

  exec { "add_${context}":
    command => shellquote('semanage', 'permissive', '-a', $context),
    unless  => sprintf('semanage permissive -l | grep -Fx %s', shellquote($context)),
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Class['selinux::package'],
  }
}
