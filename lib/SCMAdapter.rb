# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: SCMAdapter.rb

require "SCMAdapter/version"

module SCMAdapter
  autoload :AbstractAdapter, 'SCMAdapter/abstract_adapter'
  autoload :AbstractAdapterFactory, 'SCMAdapter/abstract_adapter_factory'
  autoload :Util, 'SCMAdapter/util'

  module Adapters
    autoload :GitAdapter, 'SCMAdapter/adapters/git_adapter'
    autoload :HgAdapter, 'SCMAdapter/adapters/hg_adapter'
    autoload :SvnAdapter, 'SCMAdapter/adapters/svn_adapter'
  end

  ENV_MSWIN = :mswin
  ENV_UNIX = :unix


  class CommandFailed < StandardError #:nodoc:
  end
end
