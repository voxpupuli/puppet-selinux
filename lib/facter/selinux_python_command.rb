# DEPRECATED: Determine the path to python on the system
Facter.add(:selinux_python_command) do
  confine osfamily: 'RedHat'
  setcode do
    if File.exist? '/usr/libexec/platform-python'
      # RHEL 8 / CentOS 8
      '/usr/libexec/platform-python'
    elsif Facter::Core::Execution.execute('rpm -q python3-libsemanage') !~ %r{not installed}
      'python3'
    else
      # This might be python 2 or 3. Keeping it at 'python' matches the module
      # worked previously
      'python'
    end
  end
end
