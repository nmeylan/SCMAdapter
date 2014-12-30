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

    def self.prepare_command(command, *arguments)
      arguments = arguments.compact.flatten
      command = command.dup
      unless arguments.empty?
        arguments.each do |arg|
          command << SPACE << Shellwords.shellescape(arg.to_s)
        end
      end
      command
    end

    def self.encode_str_to(str, to = Encoding::UTF_8)
      begin
        str.encode(to) unless str.encoding.name.eql?(to)
      rescue Exception => err
        raise EncodingFailed, err
      end
    end

    def popen(command, *arguments)
      command = Util::prepare_command(command, *arguments)
      self.last_executed_command = command
      logger.debug("Execute : #{command}")

      IO.popen(command, MODE, err: [:child, :out]) do |io|
        output = yield io if block_given?
      end
    end

    def write_popen(command, sub_command, write_input, *arguments)
      command = Util::prepare_command(command, *[sub_command, arguments])
      self.last_executed_command = command
      logger.debug("Execute : #{command}")
      IO.popen(command, MODE, {err: [:child, :out], write_stdin: true}) do |io|
        io.binmode
        io.puts(write_input)
        io.close_write
        output = yield io if block_given?
      end
    end

  end
end