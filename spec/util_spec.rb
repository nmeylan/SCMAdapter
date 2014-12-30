# Author: Nicolas Meylan
# Date: 29.12.14
# Encoding: UTF-8
# File: util_spec.rb

require_relative 'spec_helper'

describe SCMAdapter::Util do
  describe 'prepare command' do
    it 'prepare a command' do
      expected_result = 'git log --no-color --encoding\\=UTF-8 --raw --pretty\\=fuller --parents --stdin'
      actual_result = SCMAdapter::Util::prepare_command('git log', %w(--no-color --encoding=UTF-8 --raw  --pretty=fuller --parents --stdin))

      expect(actual_result).to eql(expected_result)
    end

    it 'prepare command without arguments' do
      expected_result = 'git log'
      actual_result = SCMAdapter::Util::prepare_command('git log')
      expect(actual_result).to eql(expected_result)
    end
  end

  describe 'encode_str_to' do
    before(:each) do
      str = 'Un text en français avec des accents à é è ü'
      @iso_8859_1_str = str.dup.encode(Encoding::ISO_8859_1)
      @utf_8_str = str.dup.encode(Encoding::UTF_8)
    end
    it 'encode from ISO_8859_1 to UTF_8' do
      expect(SCMAdapter::Util::encode_str_to(@iso_8859_1_str)).to eql(@utf_8_str)
      expect(SCMAdapter::Util::encode_str_to(@iso_8859_1_str, 'UTF-8')).to eql(@utf_8_str)
    end

    it 'encode from UTF_8 to ISO_8859_1' do
      expect(SCMAdapter::Util::encode_str_to(@utf_8_str, Encoding::ISO_8859_1)).to eql(@iso_8859_1_str)
      expect(SCMAdapter::Util::encode_str_to(@utf_8_str, 'ISO-8859-1')).to eql(@iso_8859_1_str)
    end

    it 'raise a SCMAdapter::EncodingFailed error when encoding fail' do
      expect{SCMAdapter::Util::encode_str_to(@iso_8859_1_str, 'UTF-666')}.to raise_error(SCMAdapter::EncodingFailed)
    end
  end
end