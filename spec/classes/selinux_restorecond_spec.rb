require 'spec_helper'

describe 'selinux::restorecond' do
  include_context 'RedHat 7'

  it { is_expected.to contain_class('selinux::restorecond') }
  it { is_expected.to contain_class('selinux::restorecond::config') }
  it { is_expected.to contain_class('selinux::restorecond::service') }
end
