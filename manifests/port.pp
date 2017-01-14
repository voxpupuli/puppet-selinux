# selinux::port
#
# This method will manage a local network port context setting, and will
# persist it across reboots.
# It will perform a check to ensure the network context is not already set.
#
# @example Add port-context syslogd_port_t to port 8514/tcp
#   selinux::port { 'allow-syslog-relp':
#     context  => 'syslogd_port_t',
#     protocol => 'tcp',
#     port     => '8514',
#   }
#
# @param context A port-context name
# @param protocol Either tcp or udp.
# @param port An network port number, like '8514', or a range like '1234-4321'
# @param argument *deprecated*, ignored
#
define selinux::port (
  $context,
  $port,
  $ensure = 'present',
  $protocol = undef,
  $argument = undef,
) {

  include ::selinux

  Anchor['selinux::module post'] ->
  Selinux::Port[$title] ->
  Anchor['selinux::end']

  validate_re($protocol, ['^tcp6?$', '^udp6?$'])
  selinux_port {"${protocol}_${port}":
    ensure   => $ensure,
    ports    => $port,
    context  => $context,
    protocol => $protocol,
  }
}
