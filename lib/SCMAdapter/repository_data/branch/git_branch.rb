# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_branch.rb
module SCMAdapter
  module RepositoryData
    module Branch
      class GitBranch < Branch
        attr_accessor :is_current

        def initialize(branch_name, revision)
          super(branch_name, revision)
        end

        def master?
          is_current
        end
      end
    end
  end
end