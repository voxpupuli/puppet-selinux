Puppet::Type.type(:selinux_fcontext).provide(:semanage) do
  desc 'Support managing SELinux custom fcontext definitions via semanage'

  defaultfor kernel: 'Linux'

  commands semanage: 'semanage'
  # semanage fails when SELinux is disabled, so let's not pretend to work in that situation.
  confine selinux: true

  mk_resource_methods

  osfamily  = Facter.value('osfamily')
  osversion = Facter.value('operatingsystemmajrelease')
  @old_semanage = false
  if (osfamily == 'RedHat') && (Puppet::Util::Package.versioncmp(osversion, '6') <= 0)
    @old_semanage = true
  end

  @file_types = {
    'all files' => 'a',
    'directory' => 'd',
    'character device' => 'c',
    'block device' => 'b',
    'symbolic link' => 'l',
    'named pipe' => 'p',
    'regular file' => 'f',
    'socket' => 's'
  }

  def self.file_type_map(val)
    @file_types[val]
  end

  def self.type_param(file_type)
    return file_type unless @old_semanage
    case file_type
    when 'a'
      'all files'
    when 'f'
      '--'
    else
      "-#{file_type}"
    end
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
      path_spec  = split.shift.strip
      file_type  = split.shift.strip
      context_spec = split.shift.strip
      user, role, type, range = context_spec.split(':')
      if context_spec == '<<None>>'
        # semanage is weird...
        type = '<<none>>'
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
    # Old semanage fails with --locallist, use -C
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
    # is there really no way to have a provider-global helper function cleanly?
    args = ['fcontext', '-a', '-t', @resource[:seltype], '-f', self.class.type_param(@resource[:file_type])]
    args.concat(['-s', @resource[:seluser]]) if @resource[:seluser]
    args.push(@resource[:pathspec])
    semanage(*args)
  end

  def destroy
    args = ['fcontext', '-d', '-t', @property_hash[:seltype], '-f', self.class.type_param(@property_hash[:file_type])]
    args.concat(['-s', @property_hash[:seluser]]) if @property_hash[:seluser]
    args.push(@property_hash[:pathspec])
    semanage(*args)
  end

  def seltype=(val)
    val = '<<none>>' if val == :none
    args = ['fcontext', '-m', '-t', val, '-f', self.class.type_param(@property_hash[:file_type]), @property_hash[:pathspec]]
    semanage(*args)
  end

  def seluser=(val)
    args = ['fcontext', '-m', '-s', val, '-t', @property_hash[:seltype], '-f', self.class.type_param(@property_hash[:file_type]), @property_hash[:pathspec]]
    semanage(*args)
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
