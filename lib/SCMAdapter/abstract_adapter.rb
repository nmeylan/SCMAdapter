# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: abstract_adapter.rb

require 'logger'
module SCMAdapter
  class AbstractAdapter
    def initialize(path, adapter_name, credential = nil)
      @path = path
      @adapter_name = adapter_name
      @@logger = Logger.new(STDOUT)
      @@logger.level = Logger::WARN
    end

    def exists?
      raise 'This method is not implemented yet.'
    end

    def logger
      @@logger
    end

    ####################################################
    ##                  CLASS METHODS                 ##
    ####################################################


    ####################################################
    ##                  PRIVATE METHODS               ##
    ####################################################
  end
end