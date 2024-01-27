# frozen_string_literal: true

require 'spec_helper'

describe 'example.com' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      Dir['examples/**/*.pp'].each do |example|
        context "with #{example}" do
          # Would be nicer to override the manifest
          let(:pre_condition) { File.read(example) }

          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end
end
