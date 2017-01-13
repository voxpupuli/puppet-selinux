# selinux::fcontext
#
# This method will manage a local file context setting, and will persist it across reboots.
# It will perform a check to ensure the file context is not already set.
#
# @example Add an path substition (equal) file-context
#   selinux::fcontext{'set-postfix-instance1-spool':
#     equals      => true,
#     pathname    => '/var/spool/postfix-instance1',
#     destination => '/var/spool/postfix'
#   }
#
# @example Add a file-context for mysql log files at non standard location
#   selinux::fcontext{'set-mysql-log-context':
#     context => "mysqld_log_t",
#     pathname => "/u01/log/mysql(/.*)?",
#   }
#
# example Add a file-context only for directory types 
#   selinux::fcontext{'set-non-home-user-dir_type_d':
#     filetype => true ,
#     filemode => 'd' ,
#     context  => 'user_home_dir_t' ,
#     pathname => '/u/users/[^/]*' ,
#   }
#
# @param context A particular file-context, like "mysqld_log_t"
# @param pathname An semanage fcontext-formatted pathname, like "/var/log/mysql(/.*)?"
# @param destination The destination path used with the equals parameter.
# @param equals Boolean Value - Enables support for substituting target path with sourcepath when generating default label
# @param filetype Boolean Value - enables support for "-f" file type option of "semanage fcontext"
# @param filemode File Mode for policy (i.e. regular file, directory, block device, all files, etc.)
#   - Types:
#       - a = all files (default value if not restricting filetype)
#       - f = regular file
#       - d = directory
#       - c = character device
#       - b = block device
#       - s = socket
#       - l = symbolic link
#       - p = named pipe
# @param restorecond Run restorecon against the path name upon changes (default true)
# @param restorecond_path Path name to use for restorecon (default $pathname)
# @param restorecond_recurse Run restorecon recursive?
#
define selinux::fcontext (
  $pathname,
  $destination         = undef,
  $context             = undef,
  $filetype            = false,
  $filemode            = 'a',
  $equals              = false,
  $restorecond         = true,
  $restorecond_path    = undef,
  $restorecond_recurse = false,
) {

  include ::selinux

  Anchor['selinux::module post'] ->
  Selinux::Fcontext[$title] ->
  Anchor['selinux::end']

  validate_absolute_path($pathname)
  validate_bool($filetype, $equals)

  if $equals {
    validate_absolute_path($destination)
  } else {
    validate_string($context)
  }

  $restorecond_path_private = $restorecond_path ? {
    undef   => $pathname,
    default => $restorecond_path
  }

  validate_absolute_path($restorecond_path_private)

  $restorecond_resurse_private = $restorecond_recurse ? {
    true  => ['-R'],
    false => [],
  }

  if $equals and $filetype {
    fail('Resource cannot contain both "equals" and "filetype" options')
  }

  if $equals {
    $resource_name = "add_${destination}_${pathname}"
    $command       = shellquote('semanage', 'fcontext','-a', '-e', $destination, $pathname)
    $unless        = sprintf('semanage fcontext -l | grep -Fx %s', shellquote("${pathname} = ${destination}"))
  } else {
    if $filemode !~ /^(?:a|f|d|c|b|s|l|p)$/ {
      fail('"filemode" must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"')
    }
    $resource_name = "add_${context}_${pathname}_type_${filemode}"
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '6' {
      case $filemode {
        'a': {
          $_filemode = 'all files'
          $_quotedfilemode = '\'all files\''
          }
        default: {
          $_filemode = $filemode
          $_quotedfilemode = $_filemode
        }
      }
    } else {
      $_filemode = $filemode
      $_quotedfilemode = $_filemode
    }
    $command       = shellquote('semanage', 'fcontext','-a', '-f', $_filemode, '-t', $context, $pathname)
    $unless        = sprintf('semanage fcontext -E | grep -Fx %s', shellquote("fcontext -a -f ${_quotedfilemode} -t ${context} '${pathname}'"))
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  exec { $resource_name:
    command => $command,
    unless  => $unless,
    require => Class['selinux::package'],
  }

  if $restorecond {
    exec { "restorecond ${resource_name}":
      command     => shellquote('restorecon', $restorecond_resurse_private, $restorecond_path_private),
      onlyif      => shellquote('test', '-e', $restorecond_path_private),
      refreshonly => true,
      subscribe   => Exec[$resource_name],
    }
  }

}
