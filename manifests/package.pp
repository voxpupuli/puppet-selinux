# @summary Manages additional packages required to support some of the functions.
#
# @api private
#
# @param manage_package See main class
# @param package_names See main class
# @param manage_auditd_package See main class
# @param auditd_package_name See main class
#
class selinux::package (
  Boolean $manage_package,
  Array[String[1]] $package_names,
  Boolean $manage_auditd_package,
  String[1] $auditd_package_name,
){
  assert_private()
  if $manage_package {
    ensure_packages ($package_names)
  }
  if $manage_auditd_package {
    ensure_packages ($auditd_package_name)
  }
}
