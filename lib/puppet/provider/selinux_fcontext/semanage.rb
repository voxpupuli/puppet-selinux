# frozen_string_literal: true

Puppet::Type.type(:selinux_fcontext).provide(:semanage) do
  desc 'Support managing SELinux custom fcontext definitions via semanage'

  defaultfor kernel: 'Linux'

  commands semanage: 'semanage'
  # semanage fails when SELinux is disabled, so let's not pretend to work in that situation.
  confine selinux: true

  mk_resource_methods

  @file_types = {
    'all files' => 'a',
    '-d'        => 'd',
    '-c'        => 'c',
    '-b'        => 'b',
    '-l'        => 'l',
    '-p'        => 'p',
    '--'        => 'f',
    '-s'        => 's'
  }

  def self.file_type_map(val)
    @file_types[val]
  end

  def self.parse_fcontext_lines(lines)
    lines.filter_map do |line|
      next if line.strip.empty?
      next if line.start_with?('#')

      split = line.split(%r{\s+})
      if split.length == 2
        path_spec, context_spec = split
        file_type = 'all files'
      else
        path_spec, file_type, context_spec = split
      end
      user, role, type, range = context_spec.split(':')
      if context_spec == '<<none>>'
        type = '<<none>>'
        user = range = role = nil
      end
      ft = file_type_map(file_type)

      new(ensure: :present,
          name: "#{path_spec}_#{ft}",
          pathspec: path_spec,
          seltype: type,
          seluser: user,
          selrole: role,
          selrange: range,
          file_type: ft)
    end
  end

  def self.parse_fcontext_file(path)
    return [] unless File.exist?(path)

    parse_fcontext_lines(File.readlines(path))
  end

  def self.instances
    parse_fcontext_file(Selinux.selinux_file_context_local_path)
  end

  def self.system_policy_instances
    parse_fcontext_file(Selinux.selinux_file_context_path)
  end

  def self.prefetch(resources)
    # This loads resources from built in instances. These are part of the
    # system policy. That means we can't modify them, but we should still be
    # aware of them.
    system_policy_instances.each do |provider|
      resource = resources[provider.name]
      resource.provider = provider if resource
    end

    # These are the local overrides. We prefer them over the system policy.
    instances.each do |provider|
      resource = resources[provider.name]
      resource.provider = provider if resource
    end
  end

  def create
    # is there really no way to have a provider-global helper function cleanly?
    args = ['fcontext', '-a', '-t', @resource[:seltype], '-f', @resource[:file_type]]
    args.push('-s', @resource[:seluser]) if @resource[:seluser]
    args.push(@resource[:pathspec])
    semanage(*args)
  end

  def destroy
    args = ['fcontext', '-d', '-t', @property_hash[:seltype], '-f', @property_hash[:file_type]]
    args.push('-s', @property_hash[:seluser]) if @property_hash[:seluser]
    args.push(@property_hash[:pathspec])
    semanage(*args)
  end

  def seltype=(val)
    val = '<<none>>' if val == :none
    args = ['fcontext', '-m', '-t', val, '-f', @property_hash[:file_type], @property_hash[:pathspec]]
    semanage(*args)
  end

  def seluser=(val)
    args = ['fcontext', '-m', '-s', val, '-t', @property_hash[:seltype], '-f', @property_hash[:file_type], @property_hash[:pathspec]]
    semanage(*args)
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
