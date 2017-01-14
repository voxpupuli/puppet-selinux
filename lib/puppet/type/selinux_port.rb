Puppet::Type.newtype(:selinux_port) do
  @doc = 'Manage SELinux port definitions. You should use selinux::port instead of this directly.'

  ensurable

  newparam(:title, namevar: true) do
    desc 'Should be of the form "protocol_port" or the type may misbehave'
  end

  newproperty(:ports) do
    desc 'The port or port range to manage'
    isrequired

    validate do |value|
      vals = value.split('-')
      debug(vals)
      vals.each do |val|
        val = Integer(val)
        if val < 1 || val > 65_535
          raise ArgumentError, "Illegal port value '#{val}'"
        end
      end

      if (vals.count != 1) && (Integer(vals[0]) >= Integer(vals[1]))
        raise ArgumentError, "Invalid port range #{value}"
      end
    end
  end

  newproperty(:protocol) do
    desc 'The protocol of the SELinux port definition'
    newvalues(:tcp, :udp, :ipv4, :ipv6)
    isrequired
  end

  newproperty(:context) do
    desc 'The context of the SELinux port definition'
    isrequired
  end

  newproperty(:source) do
    newvalues(:policy, :local)

    validate do |_value|
      raise ArgumentError, ':source is a read-only property'
    end
  end
end
