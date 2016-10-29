require 'spec_helper'

describe 'selinux::restorecond' do
  include_context 'RedHat 7'

  it { is_expected.to contain_concat('/etc/selinux/restorecond.conf') }
  it { is_expected.to contain_concat__fragment('restorecond_config_default') }
end
