module SCMAdapter
  module Adapters
    module GitRevisionAdapter
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

      def parse_revision(commit, content)
        parents = content.lines.first.scan(/[0-9a-f]{40}/)
        author, time = revision_parse_author_and_date(content)
        message = content =~ /^(\s{5}.*)\n\n:/m ? $1.strip! : BLANK
        files = content.scan(/^:\d+\s+\d+\s+[0-9a-f.]+\s+[0-9a-f.]+\s+(\w)\s(.+)/)
        files.collect! { |action_path| {action: action_path[0], path: action_path[1].strip} }
        SCMAdapter::RepositoryData::Revision.new(commit.scan(/[0-9a-f]{40}/).first, author, time, parents, message, files)
      end

      # More info : http://git-scm.com/docs/gitrevisions#_specifying_ranges
      def revision_specifying_range(options)
        revisions_args = []
        if options[:from] || options[:to]
          revisions_args << BLANK
          revisions_args[0] += "#{options[:from]}.." if options[:from]
          revisions_args[0] +="#{options[:to]}" if options[:to]
        elsif options[:includes] || options[:excludes]
          revisions_args += options[:includes] if options[:includes]
          revisions_args += options[:excludes].map { |r| "^#{r}" } if options[:excludes]
        elsif options[:includes_without_ancestors]
          revisions_args += options[:includes_without_ancestors].map { |r| "#{r}^!" }
        end
        revisions_args
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
        cmd_args << '--' << SCMAdapter::Util::encode_str_to(path) if path && !path.empty?
        revisions_args = revision_specifying_range(options)
        revisions = []
        write_popen(GitAdapter::GIT_LOG, revisions_args.join("\n"), cmd_args) do |io|
          output = io.gets(nil) # Get all output
          handle_error(output) if any_git_errors?(output)
          revisions = parse_revisions(output)
        end
        revisions
      rescue ScmCommandAborted => e
        logger.error "Log aborted : #{e}"
      end
    end
  end
end
