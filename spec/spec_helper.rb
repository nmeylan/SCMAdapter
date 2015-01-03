require_relative '../lib/SCMAdapter'

require 'coveralls'
Coveralls.wear!


TEST_REPO_LOCATION = 'spec_resources/git_test_repo'

RSpec.configure do |config|
  config.mock_framework = :mocha
end