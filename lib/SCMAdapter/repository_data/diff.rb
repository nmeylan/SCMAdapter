# Author: Nicolas Meylan
# Date: 28.12.14
# Encoding: UTF-8
# File: diff.rb

class Diff
  # @param [Numeric] addition : number of addition.
  # @param [Numeric] deletion :number of deletion.
  # @param [hash] files_hash : a hash that contains details of the diff, with following structure:
  # {
  #   String => {
  #     addition: {count: Numeric, content: String, from: Numeric, to: Numeric},
  #     deletion: {count: Numeric, content: String, from: Numeric, to: Numeric}
  #   }
  # }
  def initialize(addition, deletion, files_hash)
    @addition = addition
    @deletion = deletion
    @files_hash = files_hash
  end
end