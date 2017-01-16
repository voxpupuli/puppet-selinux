# selinux::port
#
# This method will manage a local network port context setting, and will
# persist it across reboots.
# It will perform a check to ensure the network context is not already set.
#
# @example Add port-context syslogd_port_t to port 8514/tcp
#   selinux::port { 'allow-syslog-relp':
#     ensure   => 'present',
#     context  => 'syslogd_port_t',
#     protocol => 'tcp',
#     port     => '8514',
#   }
#
# @param context A port-context name
# @param protocol Either 'tcp', 'udp', 'ipv4' or 'ipv6'
# @param port An network port number, like '8514', or a range like '1234-4321'
#
define selinux::port (
  String                             $seltype,
  Variant[Integer[1,65535],String]   $port,
  Enum['tcp', 'udp', 'ipv4', 'ipv6'] $protocol,
  Enum['present', 'absent']          $ensure = 'present',
) {

  include ::selinux

  if $ensure == 'present' {
    Anchor['selinux::module post'] ->
    Selinux::Port[$title] ->
    Anchor['selinux::end']
  } elsif $ensure == 'absent' {
    Class['selinux::config'] ->
    Selinux::Port[$title] ->
    Anchor['selinux::module pre']
  } else {
    fail('Unexpected $ensure value')
  }

  selinux_port {"${protocol}_${port}":
    ensure   => $ensure,
    ports    => $port, # type definition will validate this better in case it's a range
    seltype  => $seltype,
    protocol => $protocol,
  }
}
