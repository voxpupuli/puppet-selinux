module Puppet::Parser::Functions
    newfunction(:selinux_escape_perl_regexp, :type => :rvalue, :doc => <<-EOS

Escape a string so that it can be used within a perl regular expression to match a static string.
All special regexp characters will be escaped.

For example:

    $escapedRegexp = selinux_escape_perl_regexp($mystring)
    $escapedShell = selinux_sh_escape($escapedRegexp)
    exec { 'foo':
        command => "grep -P '^\d+:${escapedShell}\$' foo.txt"
    }

  EOS
) do |args|
    str = args[0]
    str = str.gsub(/\\E/, '\\E\\\\\\\\E\\Q')
    return '\\Q' + str + '\\E'
  end
end
