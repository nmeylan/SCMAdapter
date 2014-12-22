# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_adapter.rb

module SCMAdapter
  module Adapters
    class GitAdapter < AbstractAdapter
      GIT_COMMAND = 'git'.freeze
      GIT_ERRORS = %w(fatal: error:)
      # COMMANDS
      GIT_BRANCH = 'branch'.freeze
      GIT_TAG = 'tag'.freeze
      GIT_STATUS = 'status'.freeze
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

      def exists?
        status
        !failed?
      end

      def status
        output = ''
        popen(GIT_STATUS) do |io|
          io.each_line do |line|
            handle_error(line) if GIT_ERRORS.any? { |word| line.include?(word) }
            output += "#{line} \n"
          end
        end
        output
      end


      def branches
        @branches = []
        # command return : * master  c2caf9f3c33eeed9960fb6cc0de972870b38eb0b update file 1
        cmd_args = %w|--no-color --verbose --no-abbrev|
        popen(GIT_BRANCH, cmd_args) do |io|
          io.each_line do |line|
            handle_error(line) if GIT_ERRORS.any? { |word| line.include?(word) }
            branch_rev = line.match(GIT_BRANCH_REGEX)
            branch = SCMAdapter::RepositoryData::Branch::GitBranch.new(branch_rev[2], branch_rev[3])
            branch.is_current = (branch_rev[1].eql? GIT_CURRENT)
            @branches << branch
          end
        end
        @branches
      rescue ScmCommandAborted
        logger.error "Branch aborted"
      end

      def tags
        @tags = []
        popen(GIT_TAG) do |io|
          @tags = io.readlines.sort!.map(&:strip)
        end
      rescue ScmCommandAborted
        logger.error "Tag aborted"
      end

      def handle_error(output)
        super(output)
      end
    end
  end
end