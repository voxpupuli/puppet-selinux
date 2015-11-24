require 'spec_helper'

describe 'selinux' do
  include_context 'RedHat 7'

  context 'config' do
    context 'invalid mode' do
      let(:params) { { mode: 'invalid' } }
      it { expect { should create_class('selinux') }.to raise_error(/Valid modes are enforcing, permissive, and disabled.  Received: invalid/) }
    end

    context 'undef mode' do
      it { should have_file_resource_count(1) }
      it { should have_file_line_resource_count(0) }
      it { should have_exec_resource_count(0) }

      it { should contain_file('/usr/share/selinux') }
      it { should_not contain_file_line('set-selinux-config-to-enforcing') }
      it { should_not contain_file_line('set-selinux-config-to-permissive') }
      it { should_not contain_file_line('set-selinux-config-to-disabled') }
      it { should_not contain_exec('change-selinux-status-to-enforcing') }
      it { should_not contain_exec('change-selinux-status-to-permissive') }
      it { should_not contain_exec('change-selinux-status-to-disabled') }
    end

    context 'enforcing' do
      let(:params) { { mode: 'enforcing' } }

      it { should contain_file('/usr/share/selinux').with(ensure: 'directory') }
      it { should contain_file_line('set-selinux-config-to-enforcing').with(line: 'SELINUX=enforcing') }
      it { should contain_exec('change-selinux-status-to-enforcing').with(command: 'setenforce 1') }
    end

    context 'permissive' do
      let(:params) { { mode: 'permissive' } }

      it { should contain_file('/usr/share/selinux').with(ensure: 'directory') }
      it { should contain_file_line('set-selinux-config-to-permissive').with(line: 'SELINUX=permissive') }
      it { should contain_exec('change-selinux-status-to-permissive').with(command: 'setenforce 0') }
    end

    context 'disabled' do
      let(:params) { { mode: 'disabled' } }

      it { should contain_file('/usr/share/selinux').with(ensure: 'directory') }
      it { should contain_file_line('set-selinux-config-to-disabled').with(line: 'SELINUX=disabled') }
      it { should contain_exec('change-selinux-status-to-disabled').with(command: 'setenforce 0') }
    end
  end
end
