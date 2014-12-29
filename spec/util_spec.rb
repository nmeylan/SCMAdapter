# Author: Nicolas Meylan
# Date: 29.12.14
# Encoding: UTF-8
# File: util_spec.rb

require_relative 'spec_helper'

describe SCMAdapter::Util do
  describe 'prepare command' do
    it 'prepare a command' do
      expected_result = 'git log --no-color --encoding\\=UTF-8 --raw --pretty\\=fuller --parents --stdin'
      actual_result = SCMAdapter::Util.prepare_command('git log', %w(--no-color --encoding=UTF-8 --raw  --pretty=fuller --parents --stdin))

      expect(actual_result).to eql(expected_result)
    end

    it 'prepare command without arguments' do
      expected_result = 'git log'
      actual_result = SCMAdapter::Util.prepare_command('git log')
      expect(actual_result).to eql(expected_result)
    end
  end
end