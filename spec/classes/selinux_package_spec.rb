require 'spec_helper'

describe 'selinux' do
  context 'package' do
    context 'on RedHat 5 based OSes' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '5',
          selinux_current_mode: 'enforcing'
        }
      end

      it { should contain_package('policycoreutils').with(ensure: 'installed') }
    end

    %w(6 7).each do |majrelease|
      context "On RedHat #{majrelease} based OSes" do
        let(:facts) do
          {
            osfamily: 'RedHat',
            operatingsystem: 'RedHat',
            operatingsystemmajrelease: majrelease,
            selinux_current_mode: 'enforcing'
          }
        end

        it { should contain_package('policycoreutils-python').with(ensure: 'installed') }
      end
    end

    context 'On Fedora 22 based OSes' do
      include_context 'Fedora 22'

      it { should contain_package('policycoreutils-python').with(ensure: 'installed') }
    end

    context 'do not manage package' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '5'
        }
      end
      let(:params) do
        {
          manage_package: false
        }
      end

      it { should_not contain_package('policycoreutils').with(ensure: 'installed') }
    end

    context 'install a different package name' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '5'
        }
      end
      let(:params) do
        {
          package_name: 'some_package'
        }
      end

      it { should contain_package('some_package').with(ensure: 'installed') }
    end
  end
end
