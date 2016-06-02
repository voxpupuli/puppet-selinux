require 'spec_helper'

describe 'selinux::module' do
  let(:title) { 'mymodule' }
  include_context 'RedHat 7'

  context 'present case' do
    let(:params) do
      {
        source: 'test_value'
      }
    end

    it do
      should contain_file('/usr/share/selinux/local_mymodule.te').that_notifies('Exec[/usr/share/selinux/local_mymodule.pp]')

      should contain_selmodule('mymodule').with_ensure('present')
    end
  end  # context

  context 'absent case' do
    let(:params) do
      {
        ensure: 'absent',
        source: 'test_value'
      }
    end

    it do
      should contain_selmodule('mymodule')
        .with_ensure('absent')
    end
  end  # context
end # describe
