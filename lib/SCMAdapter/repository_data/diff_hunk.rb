# Author: Nicolas Meylan
# Date: 31.12.14
# Encoding: UTF-8
# File: diff_hunk.rb

# See : http://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html#Detailed-Unified
module SCMAdapter
  module RepositoryData
    class DiffHunk

      # @param [DiffHunkHeader] header : the header of the hunk.
      def initialize(from_file_header, to_file_header)
        @from_file_header = from_file_header
      end

    end
  end
end