require 'spec_helper'

describe 'selinux::restorecond' do
  let(:facts) { {
    :osfamily => 'RedHat',
    :operatingsystemmajrelease => '7',
    :selinux_current_mode => 'enforcing',
    # concat facts
    :concat_basedir => '/tmp',
    :id => 0,
    :is_pe => false,
    :path => '/tmp',
  } }

  it { should contain_concat('/etc/selinux/restorecond.conf') }
  it { should contain_concat__fragment('restorecond_config_default') }

end

