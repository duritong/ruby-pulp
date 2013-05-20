if ENV['COVERAGE'] == 'true'
  require 'simplecov'
end

require 'pulp'

RSpec.configure do |config|
  config.mock_with :mocha
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  # TODO: re-enable randomness once the tests behave in an order-agnostic way again
  # config.order = 'random'
end

class DummyResult
  def self.body
    JSON.dump(real_body)
  end

  def self.real_body
    { 'a' => 1 }
  end
end

class UnparsedDummyResult
  def self.body
    "True"
  end

  def self.real_body
    body
  end
end