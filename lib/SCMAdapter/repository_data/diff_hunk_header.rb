# Author: Nicolas Meylan
# Date: 31.12.14
# Encoding: UTF-8
# File: diff_hunk_header.rb
module SCMAdapter
  module RepositoryData
    class DiffHunkHeader
      attr_accessor :start, :count
      # @param [Numeric] start : the hunk start.
      # @param [Numeric] count : the hunk count.
      def initialize(start, count)
        @start = start
        @count = count
      end
    end
  end
end