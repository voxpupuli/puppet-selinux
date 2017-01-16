Puppet::Type.type(:selinux_port).provide(:semanage) do
  desc 'Support managing SELinux custom port definitions via semanage'

  defaultfor kernel: 'Linux'
  # SELinux must be enabled. Is there a way to get a better error message?
  confine selinux: true

  commands semanage: 'semanage'

  mk_resource_methods

  def self.parse_semanage_lines(lines, source)
    ret = {}
    lines.each do |line|
      split = line.split(%r{\s+})
      seltype = split.shift
      protocol = split.shift
      # The port-range list is comma-separated
      ports = split.map { |range| range.delete(',') }
      # interestingly enough, it is completely valid to define a port that overlaps with a port-range,
      # but if an existing *exact* definition exists, that causes problems
      ports.each do |port|
        key = "#{protocol}_#{port}"
        ret[key] = {
          ensure: :present,
          name: key,
          seltype: seltype,
          ports: port,
          protocol: protocol.to_sym,
          source: source
        }
      end
    end
    ret
  end

  def self.instances
    # no way to do this with one call as far as I know
    custom = parse_semanage_lines(semanage('port', '--list', '--locallist', '--noheading').split("\n"), :local)
    policy = parse_semanage_lines(semanage('port', '--list', '--noheading').split("\n"), :policy)
    # get rid of duplicates, as --list without --locallist returns local customisations as well
    policy.merge!(custom)
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
