Puppet::Type.type(:selinux_fcontext).provide(:semanage) do
  desc 'Support managing SELinux custom fcontext definitions via semanage'

  defaultfor kernel: 'Linux'

  commands semanage: 'semanage'
  # semanage fails when SELinux is disabled, so let's not pretend to work in that situation.
  confine selinux: true

  mk_resource_methods

  def self.file_type_map(val)
    {
      'all files' => 'a',
      'directory' => 'd',
      'character device' => 'c',
      'block device' => 'b',
      'symbolic link' => 'l',
      'named pipe' => 'p',
      'regular file' => 'f',
      'socket' => 's'
    }[val]
  end

  def self.parse_semanage_lines(lines)
    ret = []
    lines.each do |line|
      break if line =~ %r{^SELinux(.*)Equivalence(.*)}
      next if line =~ %r{^SELinux}
      next if line.strip.empty?
      # This is a bit of a hack... split only if >1 whitespace to get the
      # entirety of the middle field which can have a single space.
      # The output should never be so tight that there's only one space
      # between the first and the second fields...
      split = line.split(%r{\s{2,}})
      path_spec  = split.shift
      file_type  = split.shift
      context_spec = split.shift.strip
      user, role, type, range = context_spec.split(':')
      if context_spec == '<<None>>'
        type = :none
        # I hope this doesn't mess things up too badly...
        user = range = role = nil
      end
      ft = file_type_map(file_type)
      ret.push(new(ensure: :present,
                   name: "#{path_spec}_#{ft}",
                   pathspec: path_spec,
                   seltype: type,
                   seluser: user,
                   selrole: role,
                   selrange: range,
                   file_type: ft))
    end
    ret
  end

  def self.instances
    # With fcontext, we only need to care about local customisations as they
    # should never conflict with system policy
    parse_semanage_lines(semanage('fcontext', '--list', '--locallist').split("\n"))
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
    args = ['fcontext', '-a', '-t', @resource[:seltype], '-f', @resource[:file_type]]
    args.concat(['-s', @resource[:seluser]]) if @resource[:seluser]
    args.push(@resource[:pathspec])
    semanage(*args)
  end

  def destroy
    args = ['fcontext', '-d', '-t', @property_hash[:seltype], '-f', @property_hash[:file_type]]
    args.concat(['-s', @property_hash[:seluser]]) if @property_hash[:seluser]
    args.push(@property_hash[:pathspec])
    semanage(*args)
  end

  def seltype=(val)
    val = '<<none>>' if val == :none
    args = ['fcontext', '-m', '-t', val, '-f', @property_hash[:file_type], @property_hash[:pathspec]]
    semanage(*args)
  end

  def seluser=(val)
    args = ['fcontext', '-m', '-u', val, '-t', @property_hash[:seltype], '-f', @property_hash[:file_type], @property_hash[:pathspec]]
    semanage(*args)
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
