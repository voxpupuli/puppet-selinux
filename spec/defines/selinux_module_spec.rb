require 'spec_helper'

describe 'selinux::module' do
  let(:title) { 'mymodule' }
  include_context 'RedHat 7'

  context 'present case' do

    let(:params) {{
      :source => 'test_value'
    }}

    it { should contain_exec("mymodule-checkloaded").
           that_notifies("Exec[mymodule-buildmod]")
    }

  end  # context

  context 'absent case' do

    let(:params) {{
      :source => 'test_value',
      :ensure => 'absent'
    }}

    it { should_not contain_exec("mymodule-checkloaded").
           that_notifies("Exec[mymodule-buildmod]")
    }

  end  # context

end  # describe
