# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: branch.rb

module SCMAdapter
  module RepositoryData
    module Branch
      class Branch
        attr_accessor :revision, :branch_name

        def initialize(branch_name, revision)
          @branch_name = branch_name
          @revision = revision
        end

      end
    end
  end
end