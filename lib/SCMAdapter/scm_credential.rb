# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: scm_credential.rb

module SCMAdapter
  class ScmCredential
    def initialize(login, password)
      @login = login
      @password = password
    end
  end
end