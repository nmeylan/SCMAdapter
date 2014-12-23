# Author: Nicolas Meylan
# Date: 22.12.14
# Encoding: UTF-8
# File: author.rb
module SCMAdapter
  module RepositoryData
    class Author
      attr_accessor :name, :email

      def initialize(name, email = nil)
        @name = name
        @email = email
      end
    end
  end
end