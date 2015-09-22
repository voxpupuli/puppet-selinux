module Puppet::Parser::Functions
  newfunction(:selinux_sh_escape, :type => :rvalue, :doc => <<-EOS

Escape a string so that it can be passed on the shell within a single quoted string.

All single quotes within the string will be escaped

For example:

    $escaped = selinux_sh_escape($mystring)
    exec { 'foo':
        command => "/usr/bin/mv '{$escaped}' foo.txt"
    }

  EOS
  ) do |args|
    str = args[0]
    return str.gsub(/'/, %q!'"'"'!)
  end
end
