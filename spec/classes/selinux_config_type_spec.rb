require 'spec_helper'

describe 'selinux' do
  include_context 'RedHat 7'

  context 'config' do

    context 'invalid mode' do
      let(:params) { { :type => 'invalid' } }
      it { expect { should create_class('selinux') }.to raise_error(/Valid types are targeted, minimal, and mls.  Received: invalid/) }
    end

    context 'targeted' do
      let(:params) { { :type => 'targeted' } }

      it { should contain_file('/usr/share/selinux').with(:ensure => 'directory') }
      it { should contain_file_line('set-selinux-config-to-targeted').with(:line => 'SELINUXTYPE=targeted') }
    end

    context 'minimal' do
      let(:params) { { :type => 'minimal' } }

      it { should contain_file('/usr/share/selinux').with(:ensure => 'directory') }
      it { should contain_file_line('set-selinux-config-to-minimal').with(:line => 'SELINUXTYPE=minimal') }
    end

    context 'mls' do
      let(:params) { { :type => 'mls' } }

      it { should contain_file('/usr/share/selinux').with(:ensure => 'directory') }
      it { should contain_file_line('set-selinux-config-to-mls').with(:line => 'SELINUXTYPE=mls') }
    end

  end

end
