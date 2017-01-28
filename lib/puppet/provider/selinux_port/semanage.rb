Puppet::Type.type(:selinux_port).provide(:semanage) do
  desc 'Support managing SELinux custom port definitions via semanage'

  defaultfor kernel: 'Linux'
  # SELinux must be enabled. Is there a way to get a better error message?
  confine selinux: true

  # current file path is lib/puppet/provider/selinux_port/semanage.rb
  # semanage_ports.py is lib/puppet_x/voxpupuli/selinux/semanage_ports.py
  PORTS_HELPER = File.expand_path('../../../../puppet_x/voxpupuli/selinux/semanage_ports.py', __FILE__)
  commands semanage: 'semanage',
           python: 'python'

  mk_resource_methods

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
      port = high if high == low
      # the ports returned by the port helper are system policy first, so the provider for any local overrides
      # will come last and "win", which is the desired behaviour
      key = "#{protocol}_#{port}"
      ret[key] = {
        ensure: :present,
        name: key,
        seltype: seltype,
        ports: port,
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
        unless resource[:ports] == provider.ports && resource[:protocol] == provider.protocol || resource.purging?
          raise Puppet::ResourceError, "Selinux_port['#{resource[:name]}']: title does not match its port and protocol, and a conflicting resource exists"
        end
        resource.provider = provider
        resource[:ensure] = :present if provider.source == :policy
      else
        resources.values.each do |res|
          next unless res[:ports] == provider.ports && res[:protocol] == provider.protocol
          warning("Selinux_port['#{resource[:name]}']: title does not match format protocol_port")
          resource.provider = provider
          resource[:ensure] = :present if provider.source == :policy
        end
      end
    end
  end

  def create
    semanage('port', '-a', '-t', @resource[:seltype], '-p', @resource[:protocol], @resource[:ports])
  end

  def destroy
    semanage('port', '-d', '-p', @property_hash[:protocol], @property_hash[:ports])
  end

  def seltype=(val)
    semanage('port', '-m', '-t', val, '-p', @property_hash[:protocol], @property_hash[:ports])
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
