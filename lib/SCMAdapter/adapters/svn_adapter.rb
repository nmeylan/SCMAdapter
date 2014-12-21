# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: svn_adapter.rb

module SCMAdapter
  module Adapters
    class SvnAdapter < AbstractAdapter
      def initialize(path, credential = nil)
        super(path, :svn, credential)
      end
    end
  end
end