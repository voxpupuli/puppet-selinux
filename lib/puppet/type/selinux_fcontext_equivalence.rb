# frozen_string_literal: true

require 'pathname'

Puppet::Type.newtype(:selinux_fcontext_equivalence) do
  @doc = 'Manage SELinux fcontext equivalence definitions. You should use selinux::fcontext instead of this directly.'

  ensurable

  # The pathspec can't be the namevar because it is completely valid to have
  # two with the same spec but different file type
  newparam(:path, namevar: true) do
    desc 'The path to set equivalence for'
    validate do |value|
      raise ArgumentError, "An fcontext equivalence must specify an absolute path instead of '#{value}'" unless Pathname.new(value).absolute?
    end
  end

  newproperty(:target) do
    desc 'The target of the equivalence. ie. the path that this resource will be equivalent to'
    isrequired
    validate do |value|
      raise ArgumentError, "The fcontext equivalence target must be an absolute path instead of '#{value}'" unless Pathname.new(value).absolute?
    end
  end

  autorequire(:package) do
    %w[
      policycoreutils
      policycoreutils-python
      policycoreutils-python-utils
      python3-policycoreutils
      selinux-policy-dev
      selinux-policy-devel
    ]
  end
end
