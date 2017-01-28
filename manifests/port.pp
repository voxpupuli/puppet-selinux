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
  Enum['tcp', 'udp', 'ipv4', 'ipv6'] $protocol,
  Optional[Integer[1,65535]]         $port = undef,
  Optional[Tuple[Integer[1,65535], 2, 2]] $port_range = undef,
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

  if ($port == undef and $port_range == undef) {
    fail("You must define either 'port' or 'port_range'")
  }
  if ($port != undef and $port_range != undef) {
    fail("You can't define both 'port' and 'port_range'")
  }

  $range = $port_range ? {
    undef   => [$port, $port],
    default => $port_range,
  }

  # this can only happen if port_range is used
  if $range[0] > $range[1] {
    fail("Malformed port range: ${port_range}")
  }

  selinux_port {"${protocol}_${range[0]}-${range[1]}":
    ensure    => $ensure,
    low_port  => $range[0],
    high_port => $range[1],
    seltype   => $seltype,
    protocol  => $protocol,
  }
}
