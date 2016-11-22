require 'spec_helper'

describe 'selinux' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'config' do
        context 'invalid mode' do
          let(:params) { { mode: 'invalid' } }
          it { expect { is_expected.to create_class('selinux') }.to raise_error(%r{Valid modes are enforcing, permissive, and disabled.  Received: invalid}) }
        end

        context 'undef mode' do
          it { is_expected.to have_file_resource_count(1) }
          it { is_expected.to have_file_line_resource_count(0) }
          it { is_expected.to have_exec_resource_count(0) }
          it { is_expected.to contain_file('/usr/share/selinux') }
          it { is_expected.not_to contain_file_line('set-selinux-config-to-enforcing') }
          it { is_expected.not_to contain_file_line('set-selinux-config-to-permissive') }
          it { is_expected.not_to contain_file_line('set-selinux-config-to-disabled') }
          it { is_expected.not_to contain_exec('change-selinux-status-to-enforcing') }
          it { is_expected.not_to contain_exec('change-selinux-status-to-permissive') }
          it { is_expected.not_to contain_exec('change-selinux-status-to-disabled') }
        end

        context 'enforcing' do
          let(:params) { { mode: 'enforcing' } }

          it { is_expected.to contain_file('/usr/share/selinux').with(ensure: 'directory') }
          it { is_expected.to contain_file_line('set-selinux-config-to-enforcing').with(line: 'SELINUX=enforcing') }
          it { is_expected.to contain_exec('change-selinux-status-to-enforcing').with(command: 'setenforce 1') }
        end

        context 'permissive' do
          let(:params) { { mode: 'permissive' } }
          it { is_expected.to contain_file('/usr/share/selinux').with(ensure: 'directory') }
          it { is_expected.to contain_file_line('set-selinux-config-to-permissive').with(line: 'SELINUX=permissive') }
          it { is_expected.to contain_exec('change-selinux-status-to-permissive').with(command: 'setenforce 0') }
        end

        context 'disabled' do
          let(:params) { { mode: 'disabled' } }
          it { is_expected.to contain_file('/usr/share/selinux').with(ensure: 'directory') }
          it { is_expected.to contain_file_line('set-selinux-config-to-disabled').with(line: 'SELINUX=disabled') }
          it { is_expected.to contain_exec('change-selinux-status-to-disabled').with(command: 'setenforce 0') }
        end
      end
    end
  end
end
