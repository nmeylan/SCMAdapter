# Author: Nicolas Meylan
# Date: 31.12.14
# Encoding: UTF-8
# File: git_diff_adapter.rb
module SCMAdapter
  module Adapters
    module GitDiffAdapter
      def parse_diff_hunk_header(hunk)
        hunk.match(/^@@\s[\-](\d*)[,]?(\d*)\s[+](\d*)[,]?(\d*)\s@@(.*)/)
        SCMAdapter::RepositoryData::DiffHunkHeader.new($1, $2, $3, $4, $5)
      end

      def parse_diff_hunk(hunk)

        SCMAdapter::RepositoryData::DiffHunk.new(parse_diff_hunk_header(hunk),
                                                 *parse_hunk_content(:from, hunk),
                                                 *parse_hunk_content(:to, hunk)
        )
      end

      # @param [Symbol] source : accepted values are :from or :to.
      # @param [String] hunk_content : the content of diff hunk.
      # @return [Array] an array of size 2.
      # first index is the match result string, it is the diff hunk content
      # Second index is the number of addition/deletion of the hunk (depending of which argument "source" is given)
      def parse_hunk_content(source, hunk_content)
        raise ArgumentError.new('First params valid values are :from or :to') unless [:from, :to].include?(source)
        operator = {from: '-', to: '+'}
        match_result = hunk_content.scan(Regexp.new("^(([ \\#{operator[source]}]).*$|^)$"))
        count = match_result.inject(0) { |sum, match| operator[source].eql?(match[1]) ? sum + 1 : sum }
        match_string = match_result.collect { |match| match.first }.join("\n")
        return match_string, count
      end

      def parse_diff_hunks(hunks_content)
        hunks = []
        hunks_split = hunks_content.split(/(^@@\s[\-]\d*[,]?\d*\s[+]\d*[,]?\d*\s@@.*)/).delete_if(&:empty?)
        hunks_split.size.times do |i|
          if i % 2 == 0
            hunks << parse_diff_hunk(hunks_split[i]+hunks_split[i+1])
          end
        end
        hunks
      end
    end
  end
end