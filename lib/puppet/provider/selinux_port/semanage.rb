# frozen_string_literal: true

Puppet::Type.type(:selinux_port).provide(:semanage) do
  desc 'Support managing SELinux custom port definitions via semanage'

  defaultfor kernel: 'Linux'
  # SELinux must be enabled. Is there a way to get a better error message?
  confine 'os.selinux.enabled': true

  # Determine the appropriate python command
  def self.python_command
    @python_command ||= nil
    return @python_command if @python_command

    # Find the correct version of python on the system
    python_paths = [
      '/usr/libexec/platform-python',
      'python',
      'python3',
      'python2'
    ]

    valid_paths = []

    python_paths.each do |pypath|
      candidate = Puppet::Util.which(pypath)

      next unless candidate

      valid_paths << candidate

      if Puppet::Util::Execution.execute("#{candidate} -c 'import semanage'", failonfail: false).exitstatus.zero?
        @python_command = candidate
        break
      end
    end

    return @python_command if @python_command

    # Since this is used in 'instances', we have to shrug and hope for the
    # best unless we want runs to fail until the system is 100% correct.
    # So far, it does not appear to hurt anything in practice and preserves the
    # behavior from previous releases that hard coded the path into the python
    # script.
    valid_paths.first
  end

  # current file path is lib/puppet/provider/selinux_port/semanage.rb
  # semanage_ports.py is lib/puppet_x/voxpupuli/selinux/semanage_ports.py
  PORTS_HELPER = File.expand_path('../../../puppet_x/voxpupuli/selinux/semanage_ports.py', __dir__)
  commands semanage: 'semanage',
           python: python_command

  mk_resource_methods

  def port_range(resource_hash)
    low = resource_hash[:low_port]
    high = resource_hash[:high_port]
    if low == high
      low.to_s
    else
      "#{low}-#{high}"
    end
  end

  def self.parse_helper_lines(lines)
    ret = {}
    lines.each do |line|
      split = line.split(%r{\s+})
      # helper format is:
      # policy system_u:object_r:hi_reserved_port_t:s0 1023 512 tcp
      # local  system_u:object_r:hi_reserved_port_t:s0 1023 512 udp
      source, context, high, low, protocol = split
      seltype = context.split(':')[2]
      port = "#{low}-#{high}"
      # the ports returned by the port helper are system policy first, so the provider for any local overrides
      # will come last and "win", which is the desired behaviour
      key = "#{protocol}_#{port}"
      ret[key] = {
        ensure: :present,
        name: key,
        seltype: seltype,
        low_port: low,
        high_port: high,
        protocol: protocol.to_sym,
        source: source.to_sym
      }
    end
    ret
  end

  def self.instances
    # no way to do this with one call as far as I know
    policy = parse_helper_lines(python(PORTS_HELPER).split("\n"))
    policy.values.map do |item|
      new(item)
    end
  end

  def self.prefetch(resources)
    # is there a better way to do this? map port/protocol pairs to the provider regardless of the title
    # and make sure all system resources have ensure => :present so that we don't try to remove them
    instances.each do |provider|
      resource = resources[provider.name]
      if resource
        raise Puppet::ResourceError, "Selinux_port['#{resource[:name]}']: title does not match its port and protocol, and a conflicting resource exists" unless (resource[:low_port].to_s == provider.low_port && resource[:high_port].to_s == provider.high_port && resource[:protocol] == provider.protocol) || resource.purging?

        resource.provider = provider
        resource[:ensure] = :present if provider.source == :policy
      else
        resources.each_value do |res|
          next unless res[:low_port] == provider.low_port && res[:high_port] == provider.high_port && res[:protocol] == provider.protocol

          warning("Selinux_port['#{resource[:name]}']: title does not match format protocol_port")
          resource.provider = provider
          resource[:ensure] = :present if provider.source == :policy
        end
      end
    end
  end

  def create
    semanage('port', '-a', '-t', @resource[:seltype], '-p', @resource[:protocol], port_range(@resource))
  end

  def destroy
    semanage('port', '-d', '-p', @property_hash[:protocol], port_range(@property_hash))
  end

  def seltype=(val)
    semanage('port', '-m', '-t', val, '-p', @property_hash[:protocol], port_range(@property_hash))
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
