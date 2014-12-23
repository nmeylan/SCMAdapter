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
      command = prepare_command(command, *arguments)

      logger.debug("Execute : #{command}")

      IO.popen(command, MODE, err: [:child, :out]) do |io|
        output = yield io if block_given?
      end
    end

    def write_popen(command, sub_command, write_input, *arguments)
      command = prepare_command(command, *[sub_command, arguments])

      logger.debug("Execute : #{command}")
      IO.popen(command, MODE,{err: [:child, :out], write_stdin: true}) do |io|
        io.binmode
        io.puts(write_input)
        io.close_write
        output = yield io if block_given?
      end
    end

    def prepare_command(command, *arguments)
      arguments = arguments.compact.flatten
      command = command.dup
      unless arguments.empty?
        arguments.each do |arg|
          command << SPACE << Shellwords.shellescape(arg.to_s)
        end
      end
      command
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

    def encode_str_to(str, to = 'UTF-8')
      begin
        str.encode(to)
      rescue Exception => err
        logger.error("failed to convert to #{to}. #{err}")
        nil
      end
    end

  end
end