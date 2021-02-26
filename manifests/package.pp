# @summary Manages additional packages required to support some of the functions.
#
# @param manage_package See main class
# @param package_names See main class
# @param manage_auditd_package See main class
# @param auditd_package_name See main class
# @param setroubleshoot_package_names See main class
# @param manage_setroubleshoot_packages See main class
#
class selinux::package (
  Boolean             $manage_package                 = $selinux::manage_package,
  Variant[String[1],Array[String[1]]] $package_names                  = $selinux::package_name,
  Boolean             $manage_auditd_package          = $selinux::manage_auditd_package,
  String[1]           $auditd_package_name            = $selinux::auditd_package_name,
  Boolean             $manage_setroubleshoot_packages = $selinux::manage_setroubleshoot_packages,
  Array[String]       $setroubleshoot_package_names   = $selinux::setroubleshoot_package_names,
) {
  $_package_names = Array.new($package_names, true)
  if $manage_package {
    ensure_packages ($_package_names)
  }
  if $manage_auditd_package {
    ensure_packages ($auditd_package_name)
  }
  if $manage_setroubleshoot_packages {
    ensure_packages ($setroubleshoot_package_names)
  }
}
