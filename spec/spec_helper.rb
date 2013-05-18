require './lib/psd'

RSpec.configure do |config|
  config.filter_run :focus => true
  config.treat_symbols_as_metadata_keys_with_true_values = true
end