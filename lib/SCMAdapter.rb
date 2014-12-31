# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: SCMAdapter.rb

require "SCMAdapter/version"

module SCMAdapter
  BLANK = ''

  autoload :AbstractAdapter, 'SCMAdapter/abstract_adapter'
  autoload :AbstractAdapterFactory, 'SCMAdapter/abstract_adapter_factory'
  autoload :Util, 'SCMAdapter/util'

  module Adapters
    autoload :GitAdapter, 'SCMAdapter/adapters/git_adapter'
    autoload :HgAdapter, 'SCMAdapter/adapters/hg_adapter'
    autoload :SvnAdapter, 'SCMAdapter/adapters/svn_adapter'

    autoload :GitRevisionAdapter, 'SCMAdapter/adapters/git_adapter/git_revision_adapter'
  end

  module RepositoryData
    autoload :Branch, 'SCMAdapter/repository_data/branch'
    autoload :Revision, 'SCMAdapter/repository_data/revision'
    autoload :Author, 'SCMAdapter/repository_data/author'
  end

  ENV_MSWIN = :mswin
  ENV_UNIX = :unix


  class EncodingFailed < StandardError;
  end

  class CommandFailed < StandardError;
  end

  class ScmCommandAborted < CommandFailed;
  end

end
