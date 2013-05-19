require './lib/psd'

RSpec.configure do |config|
  unless ENV['CIRCLECI']
    config.filter_run :focus => true
  end
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
