shared_context 'RedHat 7' do
end

shared_context 'CentOS 7' do
  let(:facts) do
    {
      operatingsystem: 'CentOS',
      operatingsystemmajrelease: '7'
    }
  end
end

shared_context 'Fedora 22' do
  let(:facts) do
    {
      operatingsystem: 'Fedora',
      operatingsystemmajrelease: '22'
    }
  end
end
