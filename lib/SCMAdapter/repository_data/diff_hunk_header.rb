# Author: Nicolas Meylan
# Date: 31.12.14
# Encoding: UTF-8
# File: diff_hunk_header.rb
module SCMAdapter
  module RepositoryData
    class DiffHunkHeader
      attr_accessor :from_file_start, :from_file_count, :to_file_start, :to_file_count, :text

      # @param [Numeric] from_file_start : from file hunk start.
      # @param [Numeric] from_file_count : from file number of line modified.
      # @param [Numeric] to_file_start : to file hunk start.
      # @param [Numeric] to_file_count : to file number of line modified.
      # @param [String] text : the hunk line -1 content.
      def initialize(from_file_start, from_file_count, to_file_start, to_file_count, text)
        @from_file_start = convert_to_integer(from_file_start)
        @from_file_count = convert_to_integer(from_file_count)
        @to_file_start = convert_to_integer(to_file_start)
        @to_file_count = convert_to_integer(to_file_count)
        @text = text
      end

      def convert_to_integer(something)
        something.empty? ? nil : something.to_i
      end
    end
  end
end