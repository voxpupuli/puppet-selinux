# selinux::fcontext
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
# @param protocol Either tcp or udp. If unset, omits -p flag from semanage.
# @param port An network port number, like '8514'
# @param argument An argument for semanage port. Default: "-a"
#
define selinux::port (
  $context,
  $port,
  $protocol = undef,
  $argument = '-a',
) {

  include ::selinux

  Anchor['selinux::module post'] ->
  Selinux::Port[$title] ->
  Anchor['selinux::end']

  validate_re("${port}", '^[0-9]+(-[0-9]+)?$') # lint:ignore:only_variable_string

  if $protocol {
    validate_re($protocol, ['^tcp$', '^udp$'])
    $protocol_switch = ['-p', $protocol]
    $protocol_check = "${protocol} "
    $port_exec_command = "add_${context}_${port}_${protocol}"
  } else {
    $protocol_switch = []
    $protocol_check = '' # lint:ignore:empty_string_assignment variable is used to create regexp and undef is not possible
    $port_exec_command = "add_${context}_${port}"
  }

  exec { $port_exec_command:
    command => shellquote('semanage', 'port', $argument, '-t', $context, $protocol_switch, "${port}"), # lint:ignore:only_variable_string port can be number and we need to force it to be string for shellquote
    # This works because there seems to be more than one space after protocol and before first port
    unless  => sprintf('semanage port -l | grep -E %s', shellquote("^${context}  *${protocol_check}.* ${port}(\$|,)")),
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Class['selinux::package'],
  }
}
