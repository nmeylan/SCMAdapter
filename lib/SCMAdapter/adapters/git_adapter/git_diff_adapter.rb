# Author: Nicolas Meylan
# Date: 31.12.14
# Encoding: UTF-8
# File: git_diff_adapter.rb
module SCMAdapter
  module Adapters
    module GitDiffAdapter
      def parse_diff_hunk_header(hunk_header)
        matches = hunk_header.match(/^@@\s[\-](\d*)[,]?(\d*)\s[+](\d*)[,]?(\d*)\s@@(.*)/)
        diff_hunk_header = SCMAdapter::RepositoryData::DiffHunkHeader.new($1, $2, $3, $4, $5)
        diff_hunk_header
      end
    end
  end
end