# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: abstract_adapter_factory.rb


module SCMAdapter
  class AbstractAdapterFactory
    def self.initialize(scm_name, path, credential = nil)
      case scm_name
        when :git
          SCMAdapter::Adapters::GitAdapter.new(path, credential)
        when :svn
          SCMAdapter::Adapters::SvnAdapter.new(path, credential)
        when :hg
          SCMAdapter::Adapters::HgAdapter.new(path, credential)
        else
          raise 'This only support :git, :svn or :hg adapter'
      end
    end
  end
end