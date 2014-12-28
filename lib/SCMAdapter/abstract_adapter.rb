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
      @failed = false
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
    # Show only commits in the specified revision range.
    # @param [Hash] options : extra options to give for the command. valid keys are :
    # limit: Numeric that indicates the number of revisions to fetch.
    # reverse: true
    # from: revision from for the range.
    # to: revision to for the range.
    # includes: Array that contains revisions identifier, revision(and ancestors) in this array will be included.
    # excludes : Array that contains revisions identifier,  revision in this array will be excluded.
    # includes_exclude_ancestor: Array that contains revisions identifier, revision(without ancestors) in this array will be included.
    # Range loading :
    # from:, to: | includes:, excludes: | includes_without_ancestors:
    def revisions(path = nil, options = {})
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
      @failed = true
      raise CommandFailed, output
    end

    def failed?
      @failed
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