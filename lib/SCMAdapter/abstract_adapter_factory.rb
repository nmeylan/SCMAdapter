# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: abstract_adapter_factory.rb

require 'adapters/git_adapter'
require 'adapters/hg_adapter'
require 'adapters/svn_adapter'
module SCMAdapter
  class AbstractAdapterFactory
    def self.initialize(scm_name, path, credential = nil)
      case scm_name
        when :git
          GitAdapter.new(path, credential)
        when :svn
          SvnAdapter.new(path, credential)
        when :hg
          HgAdapter.new(path, credential)
        else
          raise 'This only support :git, :svn or :hg adapter'
      end
    end
  end
end