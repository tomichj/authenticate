$LOAD_PATH.unshift(File.dirname(__FILE__))
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)
require 'rspec/rails'
require 'shoulda-matchers'
require 'capybara/rails'
require 'capybara/rspec'
require 'database_cleaner'
require 'factory_girl'
require 'timecop'

Rails.backtrace_cleaner.remove_silencers!
DatabaseCleaner.strategy = :truncation

# No longer autoloading support, individually requiring instead.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Load factory girl factories.
Dir[File.join(File.dirname(__FILE__), 'factories/**/*.rb')].each { |f| require f }

# Build test database in rails
if defined?(ActiveRecord::Migration.maintain_test_schema!)
  ActiveRecord::Migration.maintain_test_schema! # rails 4.1+
else
  ActiveRecord::Migration.check_pending! # rails 4.0
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.infer_spec_type_from_file_location!
  config.order = :random
  config.use_transactional_fixtures = true

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.after(:each, type: :feature) do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end

def mock_request(params = {})
  req = double('request')
  allow(req).to receive(:params).and_return(params)
  allow(req).to receive(:remote_ip).and_return('111.111.111.111')
  req
end
