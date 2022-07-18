Puppet::Type.type(:selinux_login).provide(:semanage) do
  desc 'Support managing SELinux login definitions via semanage'

  defaultfor kernel: 'Linux'
  # semanage fails when SELinux is disabled, so let's not pretend to work in that situation.
  confine selinux: true

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

  # current file path is lib/puppet/provider/selinux_login/semanage.rb
  # semanage_users.py is lib/puppet_x/voxpupuli/selinux/semanage_users.py
  USERS_HELPER = File.expand_path('../../../../puppet_x/voxpupuli/selinux/semanage_users.py', __FILE__)
  commands semanage: 'semanage',
           python: python_command

  mk_resource_methods

  def self.parse_helper_lines(lines)
    ret = {}
    lines.each do |line|
      split = line.split(%r{\s+})
      # helper format is:
      # root unconfined_u
      # system_u system_u
      # __default__ unconfined_u
      # %cn_cegbu_aconex_fr-dev-ops-priv unconfined_u
      # %cn_cegbu_aconex_fr-dev-platform-priv unconfined_u
      selinux_login_name, selinux_user = split

      key = "#{selinux_login_name}"
      ret[key] = {
        ensure: :present,
        name: key,
        selinux_login_name: selinux_login_name,
        selinux_user: selinux_user
      }
    end
    ret
  end

  def self.instances
    # no way to do this with one call as far as I know
    policy = parse_helper_lines(python(USERS_HELPER).split("\n"))
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
        unless resource[:selinux_user].to_s == provider.selinux_user && resource[:selinux_login_name].to_s == provider.selinux_login_name || resource.purging?
          raise Puppet::ResourceError, "Selinux_port['#{resource[:name]}']: title does not match its port and protocol, and a conflicting resource exists"
        end
        resource.provider = provider
        resource[:ensure] = :present if provider.source == :policy
      else
        resources.values.each do |res|
          next unless res[:selinux_user] == provider.selinux_user && res[:selinux_login_name] == provider.selinux_login_name
          warning("Selinux_login['#{resource[:name]}']: title does not match format selinux_login_name_selinux_user")
          resource.provider = provider
          resource[:ensure] = :present if provider.source == :policy
        end
      end
    end
  end

  def create
    args = ['login', '-a', '-s', @resource[:selinux_user], @resource[:selinux_login_name]]
    semanage(*args)
  end

  def destroy
    args = ['login', '-d', @property_hash[:selinux_login_name]]
    semanage(*args)
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
