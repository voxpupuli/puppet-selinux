require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'puppetlabs_spec_helper/module_spec_helper'

shared_context 'RedHat 7' do
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemmajrelease => '7',
      :selinux_current_mode      => 'enforcing',
      # concat facts
      :concat_basedir => '/tmp',
      :id             => 0,
      :is_pe          => false,
      :path           => '/tmp',
    }
  end
end

shared_context 'Fedora 22' do
  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'Fedora',
      :operatingsystemmajrelease => '22',
      :selinux_current_mode      => 'enforcing',
      # concat facts
      :concat_basedir => '/tmp',
      :id             => 0,
      :is_pe          => false,
      :path           => '/tmp',
    }
  end
end
