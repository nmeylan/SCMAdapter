# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: revision.rb
module SCMAdapter
  module RepositoryData
    class Revision
      attr_accessor :identifier, :author, :date, :parent_identifier, :message, :files

      # @param [String] identifier
      # @param [Author] author
      # @param [Date] date
      # @param [String] parent_identifier
      # @param [String] message
      # @param [Array] files is an array containing hashes with the following structure :
      # [{path: '/dir/file.ext', action: '(A|C|D|M|R|T|U|X|B)'}, {...} ....]
      # see git file actions :
      # Select Added (`A`), Copied (`C`), Deleted (`D`), Modified (`M`), Renamed (`R`), have their
      # type (i.e. regular file, symlink, submodule, ...) changed (`T`), are Unmerged (`U`), are
      # Unknown (`X`), or have had their pairing Broken (`B`).
      def initialize(identifier, author, date, parent_identifier, message, files)
        @identifier = identifier #Sha for git or hg, commit number for svn.
        @author = author
        @date = date
        @parent_identifier = parent_identifier
        @message = message
        @files = files
      end
    end
  end
end