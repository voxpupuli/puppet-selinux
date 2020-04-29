require 'spec_helper'

describe 'selinux::boolean' do
  let(:title) { 'mybool' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      it { is_expected.to contain_selinux__boolean('mybool').that_requires('Anchor[selinux::module post]') }
      it { is_expected.to contain_selinux__boolean('mybool').that_comes_before('Anchor[selinux::end]') }

      context 'SELinux enabled' do
        let(:facts) do
          override_facts(super(), os: { selinux: { enabled: true } })
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

      context 'SELinux disabled' do
        let(:facts) do
          override_facts(super(), os: { selinux: { enabled: false } })
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
end
