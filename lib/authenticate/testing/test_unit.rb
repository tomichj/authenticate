require 'authenticate/testing/controller_helpers'

# Support for test unit.
#
# As of Rails 5, controller tests subclass `ActionDispatch::IntegrationTest` and should use
# IntegrationTestsSignOn to bypass the sign on screen.
class ActionController::TestCase
  include Authenticate::Testing::ControllerHelpers
end
