require 'spec_helper'

describe 'selinux::boolean' do
  let(:title) { 'mybool' }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          selinux: true,
          selinux_config_mode: 'enforcing',
          selinux_config_policy: 'targeted',
          selinux_current_mode: 'enforcing'
        )
      end

      ['on', true, 'present'].each do |value|
        context value do
          let(:params) do
            {
              ensure: value
            }
          end
          it do
            is_expected.to contain_selboolean('mybool').with(
              'value'      => 'on',
              'persistent' => true
            )
          end
        end
      end

      ['off', false, 'absent'].each do |value|
        context value do
          let(:params) do
            {
              ensure: value
            }
          end
          it do
            is_expected.to contain_selboolean('mybool').with(
              'value'      => 'off',
              'persistent' => true
            )
          end
        end
      end
    end

    # getsebool/setsebool required by selboolean type
    # don't work while selinux is in disabled mode.
    context "on #{os} with selinux disabled" do
      let(:facts) do
        hash = facts.merge(selinux: false)
        hash.delete(:selinux_config_mode)
        hash.delete(:selinux_config_policy)
        hash.delete(:selinux_current_mode)
        hash
      end

      ['on', true, 'present'].each do |value|
        context value do
          let(:params) do
            {
              ensure: value
            }
          end
          it do
            is_expected.not_to contain_selboolean('mybool')
          end
        end
      end

      ['off', false, 'absent'].each do |value|
        context value do
          let(:params) do
            {
              ensure: value
            }
          end
          it do
            is_expected.not_to contain_selboolean('mybool')
          end
        end
      end
    end
  end
end
