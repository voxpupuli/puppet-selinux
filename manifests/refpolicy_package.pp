# Manages additional packages required to support some of the functions.
#
# @param manage_package See main class
# @param package_name See main class
#
# @api private
#
class selinux::refpolicy_package (
  Boolean $manage_package = $selinux::manage_package,
  String[1] $package_name = $selinux::refpolicy_package_name,
) inherits selinux {
  assert_private()
  if $manage_package {
    ensure_packages ($package_name)
  }
}
