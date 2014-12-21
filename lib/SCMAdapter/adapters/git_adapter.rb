# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_adapter.rb
module SCMAdapter
  module Adapters
    class GitAdapter < AbstractAdapter
      def initialize(path, credential = nil)
        super(path, :git, credential)
      end
    end
  end
end