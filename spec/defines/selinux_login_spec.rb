# frozen_string_literal: true

require 'spec_helper'

describe 'selinux::login' do
  let(:title) { 'myapp' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts, 'os' => { 'selinux' => { 'enabled' => true } })
      end

      context 'ordering' do
        let(:params) do
          {
            selinux_login_name: 'localuser',
            selinux_user: 'staff_u',
            selinux_mlsrange: 's0-s0:c0.c1023'
          }
        end

        it { is_expected.to contain_selinux__login('myapp').that_requires('Anchor[selinux::module post]') }
        it { is_expected.to contain_selinux__login('myapp').that_comes_before('Anchor[selinux::end]') }
      end

      context 'with mls specified' do
        let(:params) do
          {
            selinux_login_name: 'localuser',
            selinux_user: 'staff_u',
            selinux_mlsrange: 's0-s0:c0.c1023'
          }
        end

        it { is_expected.to contain_selinux_login('localuser').with(selinux_login_name: 'localuser', selinux_user: 'staff_u', selinux_mlsrange: 's0-s0:c0.c1023') }
      end

      context 'without mls specified' do
        let(:params) do
          {
            selinux_login_name: 'localuser',
            selinux_user: 'staff_u',
          }
        end

        it { is_expected.to contain_selinux_login('localuser').with(selinux_login_name: 'localuser', selinux_user: 'staff_u') }
      end
    end
  end
end
