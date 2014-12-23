# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: branch.rb

module SCMAdapter
  module RepositoryData
    class Branch
      attr_accessor :revision, :branch_name, :is_current

      def initialize(branch_name, revision)
        @branch_name = branch_name
        @revision = revision
      end

      def master?
        is_current
      end

    end
  end
end