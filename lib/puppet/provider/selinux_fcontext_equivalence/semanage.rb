Puppet::Type.type(:selinux_fcontext_equivalence).provide(:semanage) do
  desc 'Support managing SELinux custom fcontext definitions via semanage'

  defaultfor kernel: 'Linux'

  commands semanage: 'semanage'
  confine selinux: true

  mk_resource_methods

  def self.parse_semanage_lines(lines)
    ret = []
    found_eqs = false
    lines.each do |line|
      if line =~ %r{^SELinux(.*)Equivalence(.*)}
        found_eqs = true
        next
      end
      next unless found_eqs
      next if line.strip.empty?
      source, _eq, target = line.split(%r{\s+})
      ret.push(new(ensure: :present,
                   name: source,
                   target: target))
    end
    ret
  end

  def self.instances
    # With fcontext, we only need to care about local customisations as they
    # should never conflict with system policy
    # --locallist does not work on older semanage, use -C
    parse_semanage_lines(semanage('fcontext', '--list', '-C').split("\n"))
  end

  def self.prefetch(resources)
    # is there a better way to do this? map port/protocol pairs to the provider regardless of the title
    # and make sure all system resources have ensure => :present so that we don't try to remove them
    instances.each do |provider|
      resource = resources[provider.name]
      resource.provider = provider if resource
    end
  end

  def create
    semanage('fcontext', '-a', '-e', @resource[:target], @resource[:path])
  end

  def destroy
    semanage('fcontext', '-d', '-e', @property_hash[:target], @property_hash[:name])
  end

  def target=(val)
    # apparently --modify does not work... Must delete and create anew
    # -N for noreload, so it's "atomic"
    semanage('fcontext', '-N', '-d', '-e', @property_hash[:target], @property_hash[:name])
    semanage('fcontext', '-a', '-e', val, @property_hash[:name])
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
