require 'spec_helper'

describe 'selinux' do
  [
    'RedHat 7',
    'CentOS 7',
    'Fedora 22'
  ].each do |ctx|
    context ctx do
      include_context ctx

      it { is_expected.to contain_class('selinux').without_mode }
      it { is_expected.to contain_class('selinux').without_type }
      it { is_expected.to contain_class('selinux::package') }
      it { is_expected.to contain_class('selinux::config') }
      it { is_expected.to contain_class('selinux::params') }
    end
  end
end
