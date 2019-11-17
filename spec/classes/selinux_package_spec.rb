require 'spec_helper'

describe 'selinux' do
  context 'package' do
    %w[6 7].each do |majrelease|
      context "On RedHat #{majrelease} based OSes" do
        let(:facts) do
          {
            osfamily: 'RedHat',
            operatingsystem: 'RedHat',
            operatingsystemmajrelease: majrelease,
            selinux_current_mode: 'enforcing',
            os: { release: { major: majrelease }, name: 'RedHat', family: 'RedHat' }
          }
        end

        it { is_expected.to contain_package('policycoreutils-python').with(ensure: 'present') }
        it { is_expected.not_to contain_package('auditd') }
      end
    end

    context 'On RedHat 8' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '8',
          selinux_current_mode: 'enforcing',
          os: { release: { major: '8' }, name: 'RedHat', family: 'RedHat' }
        }
      end

      it { is_expected.to contain_package('policycoreutils-python-utils').with(ensure: 'present') }
    end

    %w[24 25].each do |majrelease|
      context "On Fedora #{majrelease}" do
        let(:facts) do
          {
            osfamily: 'RedHat',
            operatingsystem: 'Fedora',
            operatingsystemmajrelease: majrelease,
            selinux_current_mode: 'enforcing',
            os: { release: { major: majrelease }, name: 'Fedora', family: 'RedHat' }
          }
        end

        it { is_expected.to contain_package('policycoreutils-python-utils').with(ensure: 'present') }
      end
    end

    context 'On the Amazon EL OS variant' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'Amazon',
          operatingsystemmajrelease: '2017',
          selinux_current_mode: 'enforcing',
          os: { release: { major: '2017' }, name: 'Amazon', family: 'RedHat' }
        }
      end

      it { is_expected.to contain_package('policycoreutils').with(ensure: 'present') }
    end

    context 'On Debian 10' do
      let(:facts) do
        {
          osfamily: 'Debian',
          operatingsystem: 'Debian',
          operatingsystemmajrelease: '10',
          selinux_current_mode: 'enforcing',
          os: { release: { major: '10' }, name: 'Debian', family: 'Debian' }
        }
      end

      %w[policycoreutils-python-utils selinux-basics selinux-policy-default auditd].each do |package|
        it { is_expected.to contain_package(package).with(ensure: 'present') }
      end
    end

    context 'do not manage package' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '7',
          os: { release: { major: 7 }, name: 'RedHat', family: 'RedHat' }
        }
      end
      let(:params) do
        {
          manage_package: false
        }
      end

      it { is_expected.not_to contain_package('policycoreutils-python').with(ensure: 'present') }
    end

    context 'install a different package name' do
      let(:facts) do
        {
          osfamily: 'RedHat',
          operatingsystem: 'RedHat',
          operatingsystemmajrelease: '7',
          os: { release: { major: 7 }, name: 'RedHat', family: 'RedHat' }
        }
      end
      let(:params) do
        {
          package_name: 'some_package'
        }
      end

      it { is_expected.to contain_package('some_package').with(ensure: 'present') }
    end
  end
end
