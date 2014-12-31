# Author: Nicolas Meylan
# Date: 31.12.14
# Encoding: UTF-8
# File: git_diff_adapter.rb
module SCMAdapter
  module Adapters
    module GitDiffAdapter
      def parse_diff_hunk_header(diff)
        diff_hunk_header = SCMAdapter::RepositoryData::DiffHunkHeader.new(nil, nil)

        diff_hunk_header
      end
    end
  end
end