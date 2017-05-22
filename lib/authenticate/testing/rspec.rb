require 'authenticate/testing/controller_helpers'
require 'authenticate/testing/view_helpers'

RSpec.configure do |config|
  config.include Authenticate::Testing::ControllerHelpers, type: :controller
  config.include Authenticate::Testing::ViewHelpers, type: :view
  config.before(:each, type: :view) do
    view.extend Authenticate::Testing::ViewHelpers::CurrentUser
  end
end
