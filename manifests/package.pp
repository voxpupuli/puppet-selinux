# @summary Manages additional packages required to support some of the functions.
#
# @api private
#
# @param manage_package See main class
# @param package_names See main class
# @param manage_auditd_package See main class
# @param auditd_package_name See main class
# @param manage_setroubleshoot_packages See main class
# @param setroubleshoot_package_names See main class
# @param manage_selinux_sandbox_packages See main class
# @param selinux_sandbox_package_names See main class
#
class selinux::package (
  Boolean $manage_package,
  Array[String[1]] $package_names,
  Boolean $manage_auditd_package,
  String[1] $auditd_package_name,
  Boolean $manage_setroubleshoot_packages,
  Array[String] $setroubleshoot_package_names,
  Boolean $manage_selinux_sandbox_packages,
  Array[String] $selinux_sandbox_package_names,
) {
  assert_private()
  if $manage_package {
    stdlib::ensure_packages ($package_names)
  }
  if $manage_auditd_package {
    stdlib::ensure_packages ($auditd_package_name)
  }
  if $manage_setroubleshoot_packages {
    stdlib::ensure_packages ($setroubleshoot_package_names)
  }
  if $manage_selinux_sandbox_packages {
    stdlib::ensure_packages ($selinux_sandbox_package_names)
  }
}
