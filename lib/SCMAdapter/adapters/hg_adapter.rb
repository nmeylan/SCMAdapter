# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: hg_adapter.rb

module SCMAdapter
  module Adapters
    class HgAdapter < AbstractAdapter
      def initialize(path, credential = nil)
        super(path, :hg, credential)
      end
    end
  end
end