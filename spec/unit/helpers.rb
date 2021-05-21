require 'chefspec'
# Webmock needs to have REXML required before, otherwise it runs into this exception when invoking Chefspec:
# uninitialized constant REXML::ParseException
# TODO: Remove this extra require when webmock will be fixed.
require 'rexml/document'
require 'webmock/rspec'

# We don't want to display the databricks settings details when running tests
ENV['databricks_details'] = '0'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    # As some errors might include HTTP content, better to put more length into error messages
    c.max_formatted_output_length = 1_000_000
  end
end
