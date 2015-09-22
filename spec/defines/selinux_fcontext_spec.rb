require 'spec_helper'

describe 'selinux::fcontext' do
  let(:title) { 'myfile' }
  include_context 'RedHat 7'

  context 'invalid pathname' do
    it { expect { is_expected.to compile }.to raise_error }
  end

  context 'equal requires destination' do
    it { expect { is_expected.to compile }.to raise_error }
  end

  context 'invalid filetype' do
    it { expect { is_expected.to compile }.to raise_error }
  end

  context 'equals and filetype' do
    it { expect { is_expected.to compile }.to raise_error }
  end

  context 'substituting fcontext' do
    let(:params) { { :pathname => '/tmp/file1', :equals => true, :destination => '/tmp/file2' } }
    it { should contain_exec('add_/tmp/file2_/tmp/file1').with(
      :command => 'semanage fcontext -a -e \'/tmp/file2\' \'/tmp/file1\'',
      :unless => 'semanage fcontext -l | grep -P \'^\Q/tmp/file1\E = \Q/tmp/file2\E$\''
    ) }
  end

  context 'substituting fcontext with special characters' do
    let(:params) { { :pathname => '/tmp/f"i$le\'1', :equals => true, :destination => '/tmp/f"i$le\'2' } }
    it { should contain_exec('add_/tmp/f"i$le\'2_/tmp/f"i$le\'1').with(
      :command => %q!semanage fcontext -a -e '/tmp/f"i$le'"'"'2' '/tmp/f"i$le'"'"'1'!,
      :unless => %q!semanage fcontext -l | grep -P '^\Q/tmp/f"i$le'"'"'1\E = \Q/tmp/f"i$le'"'"'2\E$'!
    ) }
  end

  context 'set filemode and context' do
    let(:params) { { :pathname => '/tmp/file1', :filetype => true, :filemode => 'a', :context => 'user_home_dir_t' } }
    it { should contain_exec('add_user_home_dir_t_/tmp/file1_type_a').with(
      :command => 'semanage fcontext -a -f a -t user_home_dir_t \'/tmp/file1\'',
      :unless => 'semanage fcontext -l | grep -P \'^\Q/tmp/file1\E.*:user_home_dir_t:\''
    ) }
  end

  context 'set filemode and context with special characters' do
    let(:params) { { :pathname => '/tmp/f"i$le\'1', :filetype => true, :filemode => 'a', :context => 'user_home_dir_t' } }
    it { should contain_exec('add_user_home_dir_t_/tmp/f"i$le\'1_type_a').with(
      :command => %q!semanage fcontext -a -f a -t user_home_dir_t '/tmp/f"i$le'"'"'1'!,
      :unless => %q!semanage fcontext -l | grep -P '^\Q/tmp/f"i$le'"'"'1\E.*:user_home_dir_t:'!
    ) }
  end

  context 'set context' do
    let(:params) { { :pathname => '/tmp/file1', :context => 'user_home_dir_t' } }
    it { should contain_exec('add_user_home_dir_t_/tmp/file1').with(
      :command => 'semanage fcontext -a -t user_home_dir_t \'/tmp/file1\'',
      :unless => 'semanage fcontext -l | grep -P \'^\Q/tmp/file1\E.*:user_home_dir_t:\''
    ) }
  end

  context 'set context with special characters' do
    let(:params) { { :pathname => '/tmp/f"i$le\'1', :context => 'user_home_dir_t' } }
    it { should contain_exec('add_user_home_dir_t_/tmp/f"i$le\'1').with(
      :command => %q!semanage fcontext -a -t user_home_dir_t '/tmp/f"i$le'"'"'1'!,
      :unless => %q!semanage fcontext -l | grep -P '^\Q/tmp/f"i$le'"'"'1\E.*:user_home_dir_t:'!
    ) }
  end

end
