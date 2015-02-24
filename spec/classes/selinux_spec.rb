require 'spec_helper'

describe 'selinux' do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystemmajrelease => '7', :selinux_current_mode => 'enforcing' } }

  it { should contain_class('selinux::package') }
  it { should contain_class('selinux::config') }

end
