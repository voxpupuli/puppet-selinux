require 'spec_helper'

describe 'selinux' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      context 'when in enforcing mode' do
        let(:facts) do
          override_facts(os_facts, os: { selinux: {
                           'enabled' => true,
                           'enforced' => true,
                           'config_mode' => 'enforcing',
                           'config_policy' => 'targeted',
                           'current_mode' => 'enforcing'
                         } })
        end

        context 'and requesting invalid mode' do
          let(:params) { { mode: 'invalid' } }

          it { is_expected.to compile.and_raise_error(%r{Enum}) }
        end

        context 'and no mode set' do
          it { is_expected.to have_file_resource_count(0) }
          it { is_expected.to have_file_line_resource_count(0) }
          it { is_expected.to have_exec_resource_count(0) }
          it { is_expected.not_to contain_file_line('set-selinux-config-to-enforcing') }
          it { is_expected.not_to contain_file_line('set-selinux-config-to-permissive') }
          it { is_expected.not_to contain_file_line('set-selinux-config-to-disabled') }
          it { is_expected.not_to contain_exec('change-selinux-status-to-enforcing') }
          it { is_expected.not_to contain_exec('change-selinux-status-to-permissive') }
          it { is_expected.not_to contain_exec('change-selinux-status-to-disabled') }
          it { is_expected.not_to contain_exec('activate-selinux') }
          it { is_expected.not_to contain_file('/.autorelabel') }
        end

        context 'and requesting enforcing mode' do
          let(:params) { { mode: 'enforcing' } }

          it { is_expected.to contain_file_line('set-selinux-config-to-enforcing').with(line: 'SELINUX=enforcing') }
          it { is_expected.to contain_exec('change-selinux-status-to-enforcing').with(command: 'setenforce enforcing') }
          it { is_expected.to contain_exec('change-selinux-status-to-enforcing').with(unless: "getenforce | grep -Eqi 'enforcing|disabled'") }
          it { is_expected.not_to contain_exec('activate-selinux') }
          it { is_expected.not_to contain_file('/.autorelabel') }
        end

        context 'and requesting permissive mode' do
          let(:params) { { mode: 'permissive' } }

          it { is_expected.to contain_file_line('set-selinux-config-to-permissive').with(line: 'SELINUX=permissive') }
          it { is_expected.to contain_exec('change-selinux-status-to-permissive').with(command: 'setenforce permissive') }
          it { is_expected.to contain_exec('change-selinux-status-to-permissive').with(unless: "getenforce | grep -Eqi 'permissive|disabled'") }
          it { is_expected.not_to contain_exec('activate-selinux') }
          it { is_expected.not_to contain_file('/.autorelabel') }
        end

        context 'and requesting disabled mode' do
          let(:params) { { mode: 'disabled' } }

          it { is_expected.to contain_file_line('set-selinux-config-to-disabled').with(line: 'SELINUX=disabled') }
          it { is_expected.not_to contain_file('/.autorelabel') }
        end
      end

      context 'when in disabled mode' do
        let(:facts) do
          # Get a deep copy and then fully override the selinux facts
          result = override_facts(os_facts)
          result[:os]['selinux'] = { 'enabled' => false }
          result
        end

        %w[permissive enforcing].each do |target_mode|
          context "and requesting #{target_mode} mode" do
            let(:params) { { mode: target_mode } }

            if os_facts[:osfamily] == 'Debian'
              it { is_expected.to contain_exec('activate-selinux') }
            else
              it { is_expected.not_to contain_exec('activate-selinux') }
            end
            it { is_expected.to contain_file('/.autorelabel').with(ensure: 'file', content: '') }
          end
        end
      end
    end
  end
end
