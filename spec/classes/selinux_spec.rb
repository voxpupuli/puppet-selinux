require 'spec_helper'

describe 'selinux' do
  context 'Redhat 7' do
    include_context 'RedHat 7'

    it { should contain_class('selinux::package') }
    it { should contain_class('selinux::config') }
  end

  context 'Fedora 22' do
    include_context 'Fedora 22'

    it { should contain_class('selinux::package') }
    it { should contain_class('selinux::config') }
  end
end
