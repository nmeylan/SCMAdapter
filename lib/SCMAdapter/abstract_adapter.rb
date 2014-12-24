# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: abstract_adapter.rb

require 'logger'
require 'pathname'
module SCMAdapter
  class AbstractAdapter
    # See implementation in the "adapters" folder
    include SCMAdapter::Util
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
      @branches = nil
    end

    ####################################################
    ##                  COMMANDS                      ##
    ####################################################
    def branches
      raise 'This method should be overridden into subclasses.'
    end

    def tags
      raise 'This method should be overridden into subclasses.'
    end

    # @param [String] path : Show only commits that are enough to explain how the files that match the specified paths came to be.
    # @param [String] identifier_from : revision from for the range.
    # @param [String] identifier_to : revision to for the range.
    # Show only commits in the specified revision range.
    # @param [Hash] options : extra options to give for the command. valid keys are :
    # :limit, :reverse, :include, :exclude
    # limit: Numeric that indicates the number of revisions to fetch.
    # reverse: true
    # include: Array that contains revisions identifier
    def revisions(path = nil, identifier_from = nil, identifier_to = nil, options = {})
      raise 'This method should be overridden into subclasses.'
    end

    ####################################################
    ##                  MISC                          ##
    ####################################################
    def exists?
      raise 'This method should be overridden into subclasses.'
    end

    def logger
      @@logger
    end

    def handle_error(output)
      logger.warn(output)
      raise CommandFailed, output
    end

    # Runs a command as a separate process.
    # @param [Symbol] sub_command The sub-command to run. the scm command, e.g : 'commit', 'add'.
    # @param [Array] arguments Additional arguments to pass to the command.
    # @yield [line] The given block will be passed.
    #
    # @return [IO] The stdout of the command being ran.
    #
    def popen(sub_command, *arguments, &block)
      Dir.chdir(@path) do
        super(*[self.class.command, sub_command], arguments, &block)
      end
    end

    def write_popen(sub_command, write_input, *arguments, &block)
      Dir.chdir(@path) do
        super(self.class.command,sub_command, write_input, arguments, &block)
      end
    end

    ####################################################
    ##                  CLASS METHODS                 ##
    ####################################################

    def self.logger
      @@logger
    end

    def self.command
      raise 'This method should be overridden into subclasses.'
    end

    ####################################################
    ##                  PRIVATE METHODS               ##
    ####################################################
  end
end