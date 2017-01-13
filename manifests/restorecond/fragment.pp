# selinux::restorecond::fragment
#
# @param content Fragment content (use either content or source)
# @param source Fragment file source (use either content or source)
# @param order Order of fragment
define selinux::restorecond::fragment (
  $content = undef,
  $source = undef,
  $order = '10'
) {

  if !defined(Class['selinux::restorecond']) {
    fail('You must include the restorecond base class before using any restorecond defined resources')
  }

  concat::fragment{ "restorecond_conf_${name}":
    target  => $selinux::restorecond::config_file,
    content => $content,
    source  => $source,
    order   => $order,
  }
}
