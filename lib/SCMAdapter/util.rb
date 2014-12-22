# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: util.rb
require 'fileutils'
require 'shellwords'

module SCMAdapter
  module Util
    SPACE = ' '.freeze
    MODE = 'r+'.freeze

    def popen(command, *arguments)
      arguments = arguments.compact.flatten
      command = command.dup
      unless arguments.empty?
        arguments.each do |arg|
          command << SPACE << Shellwords.shellescape(arg.to_s)
        end
      end

      logger.warn("Execute : #{command}")

      IO.popen(command, MODE, err: [:child, :out]) do |io|
        output = yield io if block_given?
      end
    end

    def readlines_until(io, separator='')
      lines = []

      until io.eof?
        line = io.readline
        line.chomp!

        break if line == separator

        lines << line
      end

      lines
    end

  end
end