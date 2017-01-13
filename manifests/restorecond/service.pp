# selinux::restorecond::service
#
# THIS IS A PRIVATE CLASS
# =======================
#
# manages restorecond service
class selinux::restorecond::service {

  service{'restorecond':
    ensure => running,
    enable => true,
  }
}
