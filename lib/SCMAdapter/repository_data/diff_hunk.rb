# Author: Nicolas Meylan
# Date: 31.12.14
# Encoding: UTF-8
# File: diff_hunk.rb

# See : http://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html#Detailed-Unified
module SCMAdapter
  module RepositoryData
    class DiffHunk
      attr_accessor :header, :from_file_content, :to_file_content, :number_additions , :number_deletions
      # @param [DiffHunkHeader] header : the header of the hunk.
      def initialize(header, from_file_content, number_deletions, to_file_content, number_additions)
        @header = header
        @from_file_content = from_file_content
        @to_file_content = to_file_content
        @number_additions = number_additions
        @number_deletions = number_deletions
      end

    end
  end
end