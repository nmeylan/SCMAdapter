require_relative '../lib/SCMAdapter'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.mock_framework = :mocha
end