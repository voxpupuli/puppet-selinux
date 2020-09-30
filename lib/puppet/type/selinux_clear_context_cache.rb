require 'puppet/util/selinux'

Puppet::Type.newtype(:selinux_clear_context_cache) do
  desc <<-DOC
  @summary
    A simple metaresource type that invalidates the SELinux default file context cache when refreshed.

  @example Using the type
    package {'foo': ensure => installed }
    ~> selinux_clear_context_cache {'clear the selinux cache after installing foo':}
    -> Class['foo::config']

  DOC
  newparam :name do
    desc 'Arbitary name of the resource instance.  Only used for uniqueness.'
    isnamevar
  end

  def refresh
    return unless Puppet::Util::SELinux.selinux_support?

    Puppet.debug 'Clearing Selinux default file context cache'
    Selinux.matchpathcon_fini
  end
end
