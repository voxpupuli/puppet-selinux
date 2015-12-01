require 'spec_helper'

describe 'selinux::boolean' do
  let(:title) { 'mybool' }
  include_context 'RedHat 7'

  ['on', true, 'present'].each do |value|
    context value do
      let(:params) do
        {
          ensure: value
        }
      end
      it do
        should contain_selboolean('mybool').with(
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
        should contain_selboolean('mybool').with(
          'value'      => 'off',
          'persistent' => true
        )
      end
    end
  end
end
