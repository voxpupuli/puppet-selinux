Puppet::Type.newtype(:selinux_login) do
  @doc = 'Manage SELinux login definitions. You should use selinux::login instead of this directly.'

  ensurable

  newparam(:title, namevar: true) do
    desc 'Should be of the form "linuxuser_selinuxuser" or the type may misbehave'
  end

  newproperty(:selinux_login_name) do
    desc 'The name of the linux user or group to map.'
    isrequired
  end

  newproperty(:selinux_user) do
    desc 'The selinux user to map to.'
    isrequired
  end

  autorequire(:package) do
    [
      'policycoreutils',
      'policycoreutils-python',
      'policycoreutils-python-utils',
      'python3-policycoreutils',
      'selinux-policy-dev',
      'selinux-policy-devel'
    ]
  end
end
