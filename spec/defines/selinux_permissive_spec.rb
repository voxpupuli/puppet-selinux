require 'spec_helper'

describe 'selinux::permissive' do
  let(:title) { 'mycontextp' }
  include_context 'RedHat 7'

  context 'context allow-oddjob_mkhomedir_t to permissive' do
    let(:params) do
      {
        context: 'oddjob_mkhomedir_t'
      }
    end

    it do
      is_expected.to contain_exec('add_oddjob_mkhomedir_t').with(command: 'semanage permissive -a oddjob_mkhomedir_t')
    end
  end  # context

end
