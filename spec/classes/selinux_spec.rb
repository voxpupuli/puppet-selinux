require 'spec_helper'

describe 'selinux' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { is_expected.to contain_class('selinux').without_mode }
      it { is_expected.to contain_class('selinux').without_type }
      it { is_expected.to contain_class('selinux::package') }
      it { is_expected.to contain_class('selinux::config') }
      it { is_expected.to contain_class('selinux::params') }
      it { is_expected.to contain_anchor('selinux::start').that_comes_before('Class[selinux::package]') }
      it { is_expected.to contain_anchor('selinux::module pre').that_requires('Class[selinux::config]') }
      it { is_expected.to contain_anchor('selinux::module pre').that_comes_before('Anchor[selinux::module post]') }
      it { is_expected.to contain_anchor('selinux::module post').that_comes_before('Anchor[selinux::end]') }
      it { is_expected.to contain_anchor('selinux::end').that_requires('Anchor[selinux::module post]') }
    end
  end
end
