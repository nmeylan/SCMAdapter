# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_adapter.rb

module SCMAdapter
  module Adapters
    class GitAdapter < AbstractAdapter
      GIT_COMMAND = 'git'
      GIT_ERROR_START = 'fatal:'

      def initialize(path, credential = nil)
        super(path, :git, credential)
      end

      class << self
        def command
          GIT_COMMAND
        end
      end

      def status
        output = ''
        popen('status') do |io|
          io.each_line do |line|
            output += "#{line} \n"
          end
          handle_error(output)
        end
        output
      end

      def handle_error(output)
        super(output) if output.start_with?(GIT_ERROR_START)
      end
    end
  end
end