Puppet::Type.newtype(:selinux_fcontext) do
  @doc = 'Manage SELinux fcontext definitions. You should use selinux::fcontext instead of this directly.'

  ensurable

  # The pathspec can't be the namevar because it is completely valid to have
  # two with the same spec but different file type
  newparam(:title, namevar: true) do
    desc 'The namevar. Should be of the format pathspec_filetype'
  end

  newparam(:pathspec) do
    desc 'Path regular expression'
    isrequired
  end

  newproperty(:file_type) do
    desc 'The file type to match'
    # See semanage manual page.
    newvalues(%r{^[abcdflps]$})
    defaultto 'a'
    isrequired
  end

  newproperty(:context) do
    desc 'The SELinux type to apply to the paths'
    isrequired
    newvalues(%r{\w+})
  end

  newproperty(:user) do
    desc 'The SELinux user name'
    newvalues(%r{\w+})
  end
end
