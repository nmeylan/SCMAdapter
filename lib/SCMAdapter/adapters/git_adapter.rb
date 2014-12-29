# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_adapter.rb

module SCMAdapter
  module Adapters
    class GitAdapter < AbstractAdapter
      GIT_COMMAND = 'git'.freeze
      GIT_ERRORS = %w(fatal: error: is\ not\ a\ git\ command)
      # COMMANDS
      GIT_BRANCH = 'branch'.freeze
      GIT_TAG = 'tag'.freeze
      GIT_STATUS = 'status'.freeze
      GIT_LOG = 'log'.freeze
      # Other
      GIT_CURRENT = '*'.freeze
      BLANK = ''
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

      # @param [String] path
      # @param [Hash] options : @see super class AbstractAdapter for available options.
      def revisions(path = nil, options = {})
        # A commit looks like :
        # commit c2caf9f3c33eeed9960fb6cc0de972870b38eb0b 74a2e4c6fff876a366b5249916f398f5690fd446
        # Author:     author <author@gmail.com>
        # AuthorDate: Sun Dec 21 15:39:37 2014 +0100
        # Commit:     author <author@gmail.com>
        # CommitDate: Sun Dec 21 15:39:37 2014 +0100
        #
        #     update file 1
        #     Commit message blllall
        #
        # :100644 100644 e69de29... da31a04... M  file1.txt
        cmd_args = %w(--no-color --encoding=UTF-8 --raw  --pretty=fuller --parents --stdin)
        cmd_args << '--reverse' if options[:reverse]
        cmd_args << '-n' << "#{options[:limit].to_i}" if options[:limit]
        cmd_args << '--' << encode_str_to(path) if path && !path.empty?
        revisions_args = revision_specifying_range(options)
        revisions = []
        write_popen(GIT_LOG, revisions_args.join("\n"), cmd_args) do |io|
          output = io.gets(nil) # Get all output
          handle_error(output) if GIT_ERRORS.any? { |word| output.include?(word) }

          revisions = parse_revisions(output)
        end
        revisions
      rescue ScmCommandAborted => e
        logger.error "Log aborted : #{e}"
      end

      def parse_revisions(text_entry)
        revisions = []
        commits = text_entry.split(/^(commit [0-9a-f]{40})/).delete_if(&:empty?)
        if commits.any?
          commits_hash = Hash[*commits]
          commits_hash.each do |commit, content|
            revisions << parse_revision(commit, content)
          end
        end
        revisions
      end

      # More info : http://git-scm.com/docs/gitrevisions#_specifying_ranges
      def revision_specifying_range(options)
        revisions_args = []
        if options[:from] || options[:to]
          revisions_args << BLANK
          revisions_args[0] += "#{options[:from]}.." if options[:from]
          revisions_args[0] +="#{options[:to]}" if options[:to]
        elsif options[:includes] || options[:includes]
          revisions_args += options[:includes] if options[:includes]
          revisions_args += options[:excludes].map { |r| "^#{r}" } if options[:excludes]
        elsif options[:includes_without_ancestors]
          revisions_args += options[:includes_without_ancestors].map { |r| "#{r}^!" }
        end
        revisions_args
      end

      def parse_revision(commit, content)
        parents = content.lines.first.scan(/[0-9a-f]{40}/)
        author, time = revision_parse_author_and_date(content)
        message = content =~ /^(\s{5}.*)\n\n:/m ? $1.strip! : BLANK
        files = content.scan(/^:\d+\s+\d+\s+[0-9a-f.]+\s+[0-9a-f.]+\s+(\w)\s(.+)/)
        files.collect! { |action_path| {action: action_path[0], path: action_path[1].strip} }
        SCMAdapter::RepositoryData::Revision.new(commit.scan(/[0-9a-f]{40}/).first, author, time, parents, message, files)
      end

      def revision_parse_author_and_date(content)
        author = time = nil
        content.each_line do |line|
          if line =~ /^(\w+):\s*(.*)$/
            key = $1
            value = $2
            if key.eql?('Author')
              value.scan(/(^.*)<(.*)>/)
              author = SCMAdapter::RepositoryData::Author.new($1.strip!, $2)
            elsif key.eql?('CommitDate')
              time = Time.parse(value)
            end
          end
        end
        return author, time
      end

      # @param [String] commit_identifier : the commit identifier to perform the diff with its parents.
      # @param [String] path : diff only a given file.
      def diff(commit_identifier, path = nil)

      end

      def handle_error(output)
        super(output)
      end
    end
  end
end