# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: abstract_adapter.rb

require 'logger'
require 'pathname'
module SCMAdapter
  class AbstractAdapter

    attr_accessor :path, :adapter_name, :credential, :branches

    @@logger = Logger.new(STDOUT)
    @@logger.level = Logger::WARN
    @@logger.formatter =  ->(severity, datetime, progname, msg) do
      "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} - #{sprintf('%-5s',severity)} - #{msg}\n"
    end

    def initialize(path, adapter_name, credential)
      @path = Pathname.new(File.expand_path(path))
      @adapter_name = adapter_name
      @credential = credential
      @failed = false
      @branches = nil
    end

    ####################################################
    ##                  COMMANDS                      ##
    ####################################################
    def branches
      raise 'This method is not implemented yet.'
    end

    def tags
      raise 'This method is not implemented yet.'
    end

    ####################################################
    ##                  MISC                          ##
    ####################################################
    def exists?
      raise 'This method is not implemented yet.'
    end

    def logger
      @@logger
    end

    def handle_error(output)
      logger.warn(output)
      @failed = true
      raise CommandFailed, output
    end

    def failed?
      @failed
    end

    # Runs a command as a separate process.
    # @param [Symbol] sub_command The sub-command to run.
    # @param [Array] arguments Additional arguments to pass to the command.
    # @yield [line] The given block will be passed.
    #
    # @return [IO] The stdout of the command being ran.
    #
    def popen(sub_command, *arguments, &block)
      Dir.chdir(@path) do
        self.class.popen(sub_command, arguments, &block)
      end
    end

    ####################################################
    ##                  CLASS METHODS                 ##
    ####################################################
    extend SCMAdapter::Util

    def self.logger
      @@logger
    end

    def self.command
      raise 'This method is not implemented yet.'
    end

    # @param [String] sub_command : the scm command, e.g : 'commit', 'add'.
    # @param [Array] arguments : the arguments for the command.
    # @param [Array] options : additional options.
    # @param [Block] block.
    def self.popen(sub_command, arguments, options=nil, &block)
      super(*[command, sub_command], arguments, options, &block)
    end

    ####################################################
    ##                  PRIVATE METHODS               ##
    ####################################################
  end
end