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
# @param filetype Boolean Value *deprecated* ignored
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
  String $pathname,
  Enum['absent', 'present'] $ensure  = 'present',
  Optional[String] $destination      = undef,
  Optional[String] $context          = undef,
  Boolean $filetype                  = false, # ignored, 
  Optional[String] $user             = undef,
  Optional[String] $filemode         = 'a',
  Boolean $equals                    = false,
  Boolean $restorecond               = true,
  Optional[String] $restorecond_path = undef,
  Boolean $restorecond_recurse       = false,
) {

  include ::selinux
  Anchor['selinux::module post'] ->
  Selinux::Fcontext[$title] ->
  Anchor['selinux::end']

  validate_absolute_path($pathname)

  if $filetype {
    deprecation('selinux_fcontext_filetype', 'The selinux::fcontext::filetype parameter is deprecated and does nothing')
  }

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

  if $equals and $context != undef {
    fail('Resource cannot set both "equals" and "context" as they are mutually exclusive')
  }

  if $equals {
    selinux_fcontext_equivalence {$pathname:
      target => $destination,
    }
    if $restorecond {
      Selinux_fcontext_equivalence[$pathname] ~> Exec["restorecond semanage::fcontext[${pathname}]"]
    }
  } else {
    if $filemode !~ /^(?:a|f|d|c|b|s|l|p)$/ {
      fail('"filemode" must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"')
    }

    # make sure the title is correct or the provider will misbehave
    selinux_fcontext {"${pathname}_${filemode}":
      pathspec  => $pathname,
      context   => $context,
      file_type => $filemode,
      user      => $user,
    }
    if $restorecond {
      Selinux_fcontext["${pathname}_${filemode}"] ~> Exec["restorecond semanage::fcontext[${pathname}]"]
    }
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if $restorecond {
    exec { "restorecond semanage::fcontext[${pathname}]":
      command     => shellquote('restorecon', $restorecond_resurse_private, $restorecond_path_private),
      onlyif      => shellquote('test', '-e', $restorecond_path_private),
      refreshonly => true,
    }
  }
}
