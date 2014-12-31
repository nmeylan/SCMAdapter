# Author: Nicolas Meylan
# Date: 28.12.14
# Encoding: UTF-8
# File: diff.rb
module SCMAdapter
  module RepositoryData
    class Diff
      # @param [Numeric] addition : numbers of addition.
      # @param [Numeric] deletion : numbers of deletion.
      # @param [Array] hunks : an Array containg hunks of difference.
      def initialize(addition, deletion, files_hash)
        @addition = addition
        @deletion = deletion
        @files_hash = files_hash
      end
    end
  end
end