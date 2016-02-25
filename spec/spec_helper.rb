$LOAD_PATH.unshift(File.dirname(__FILE__))
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'shoulda-matchers'
require 'capybara/rails'
require 'capybara/rspec'
require 'database_cleaner'
require 'factory_girl_rails'
require 'controller_helpers'
require 'timecop'

Rails.backtrace_cleaner.remove_silencers!
DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.include Authenticate::Testing::ControllerHelpers, type: :controller
  config.include FactoryGirl::Syntax::Methods

  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false

  config.after(:each, :type => :feature) do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end


def restore_default_configuration
  Authenticate.configuration = nil
  Authenticate.configure {}
end

def mock_request(params = {})
  req = double("request")
  allow(req).to receive(:params).and_return(params)
  allow(req).to receive(:remote_ip).and_return('111.111.111.111')
  req
end
