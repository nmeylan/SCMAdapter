# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_adapter.rb

module SCMAdapter
  module Adapters
    class GitAdapter < AbstractAdapter
      include SCMAdapter::Adapters::GitRevisionAdapter
      GIT_COMMAND = 'git'.freeze
      GIT_ERRORS = %w(fatal: error: is\ not\ a\ git\ command)
      # COMMANDS
      GIT_BRANCH = 'branch'.freeze
      GIT_TAG = 'tag'.freeze
      GIT_STATUS = 'status'.freeze
      GIT_LOG = 'log'.freeze
      # Other
      GIT_CURRENT = '*'.freeze
      #REGEX
      # first group select the 'star' for current branch
      # second groupd select the branch name
      # third group select the revision sha1
      GIT_BRANCH_REGEX = '\s*(\*?)\s*(.*?)\s*([0-9a-f]{40}).*$'

      def initialize(path, credential = nil)
        super(path, :git, credential)
      end

      class << self
        def command
          GIT_COMMAND
        end
      end

      def version
        result = nil
        popen(nil, %w(--version)) do |io|
          result = io.gets(nil)
        end
        handle_error(result) if GIT_ERRORS.any? { |word| result.include?(word) }
        result
      rescue ScmCommandAborted => e
        logger.error "--version aborted : #{e}"
      end

      def branches
        @branches = []
        # command return : * master  c2caf9f3c33eeed9960fb6cc0de972870b38eb0b update file 1
        cmd_args = %w(--no-color --verbose --no-abbrev)
        popen(GIT_BRANCH, cmd_args) do |io|
          io.each_line do |line|
            handle_error(line) if GIT_ERRORS.any? { |word| line.include?(word) }
            branch_rev = line.match(GIT_BRANCH_REGEX)
            branch = SCMAdapter::RepositoryData::Branch.new(branch_rev[2], branch_rev[3])
            branch.is_current = (branch_rev[1].eql? GIT_CURRENT)
            @branches << branch
          end
        end
        @branches
      rescue ScmCommandAborted => e
        logger.error "Branch aborted : #{e}"
      end

      def tags
        @tags = []
        popen(GIT_TAG) do |io|
          @tags = io.readlines.sort!.map(&:strip)
        end
      rescue ScmCommandAborted => e
        logger.error "Tag aborted : #{e}"
      end


      # @param [String] commit_identifier : the commit identifier to perform the diff with its parents.# @param [String] path : diff only a given file.
      def diff(commit_identifier, path = nil)

      end

      def handle_error(output)
        super(output)
      end

      def any_git_errors?(output)
        GIT_ERRORS.any? { |word| output.include?(word) }
      end
    end
  end
end