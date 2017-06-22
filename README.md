# Authenticate

A Rails authentication gem.

Authenticate is small, simple, but extensible. It has highly opinionated defaults but is
open to significant modification.

Authenticate is inspired by, and draws from, Devise, Warden, Authlogic, Clearance, Sorcery, and restful_authentication.

Please use [GitHub Issues] to report bugs. You can contact me directly on twitter 
[@JustinTomich](https://twitter.com/justintomich).

[GitHub Issues]: https://github.com/tomichj/authenticate/issues

[![Gem Version](https://badge.fury.io/rb/authenticate.svg)](https://badge.fury.io/rb/authenticate) ![Build status](https://travis-ci.org/tomichj/authenticate.svg?branch=master) ![Code Climate](https://codeclimate.com/github/tomichj/authenticate/badges/gpa.svg)


## Philosophy

* simple - Authenticate's code is straightforward and easy to read. No middleware!
* opinionated - set the "right" defaults, but let you control almost everything if you want
* small footprint - as few public methods and modules as possible. Methods only loaded into your user model if needed.
* configuration driven - almost all configuration is performed in the initializer


## Implementation Overview

Authenticate:
* loads modules into your user model to provide authentication functionality
* loads `callbacks` that are triggered during authentication and access events. All authentication
decisions are performed in callbacks, e.g. do you have a valid session, has your session timed out, etc.
* loads a module into your controllers (typically `ApplicationController`) to secure controller actions

The callback architecture is based on the system used by devise and warden, but significantly simplified.


### Session Token

Authenticate generates a token (called a 'session token') to identify the user from a saved cookie.
When a user authenticates successfully, Authenticate generates and stores a 'session token' for your user in
your database. The session token is also stored in a cookie in the user's browser.
The cookie is then presented upon each subsequent access attempt to your server.


## Install

To get started, add Authenticate to your `Gemfile` and run `bundle install` to install it:

```ruby
gem 'authenticate'
```

Then run the authenticate install generator:

```sh
rails generate authenticate:install
```

The generator does the following:

* Insert `include Authenticate::User` into your `User` model. If you don't have a User model, one is created.
* Insert `include Authenticate::Controller` into your `ApplicationController`
* Add an initializer at `config/initializers/authenticate.rb`.
* Create migrations to create a users table or add columns to your existing table.


You'll need to run the migrations that Authenticate just generated:

```sh
rake db:migrate
```

Finally, you need to secure any controllers that require authentication by adding   
`before_action :require_login`. If your entire app requires authentication, add it to 
`ApplicationController`:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Authenticate::Controller
  before_action :require_login
  protect_from_forgery with: :exception
end
```


## Configure

Override any of these defaults in your application `config/initializers/authenticate.rb`.

```ruby
Authenticate.configure do |config|
  config.user_model = 'User'
  config.cookie_name = 'authenticate_session_token'
  config.cookie_expiration = { 1.year.from_now.utc }
  config.cookie_domain = nil
  config.cookie_path = '/'
  config.secure_cookie = false
  config.cookie_http_only = false
  config.mailer_sender = 'reply@example.com'
  config.crypto_provider = Bcrypt
  config.timeout_in = nil
  config.max_session_lifetime = nil
  config.max_consecutive_bad_logins_allowed = nil
  config.bad_login_lockout_period = nil
  config.password_length = 8..128
  config.authentication_strategy = :email
  config.redirect_url = '/'
  config.allow_sign_up = true
  config.routes = true
  config.reset_password_within = 2.days
end
```

Configuration parameters are described in detail here: [Configuration](lib/authenticate/configuration.rb)


## Use

### Access Control

Use the `require_login` filter to control access to controller actions. To control access to
all controller actions, add the filter to your `ApplicationController`, e.g.:

```ruby
class ApplicationController < ActionController::Base
    before_action :require_login
end
```


### Authentication

Authenticate provides a session controller and views to authenticate users with an email and password.
After successful authentication, the user is redirected to the path they attempted to access, 
or as specified by the `redirect_url` property in your configuration. This defaults to '/' but can customized:

```ruby
Authenticate.configure do |config|
  config.redirect_url = '/specials'
end
```


### Helpers

Use `current_user`, `logged_in?`, and `logged_out?` in controllers, views, and helpers.

Example:

```erb
<% if logged_in? %>
  <%= current_user.email %>
  <%= link_to "Sign out", sign_out_path %>
<% else %>
  <%= link_to "Sign in", sign_in_path %>
<% end %>
```


### Logout

Log the user out. The user session_token will be deleted from the database, and the session cookie will
be deleted from the user's browser session.

```ruby
# in session controller...
def destroy
  logout
  redirect_to '/', notice: 'You logged out successfully'
end
```


### Password Resets

Authenticate provides password reset controllers and views. When a user requests a password reset, Authenticate
delivers an email to that user. Change your `mailer_sender`, which is used in the email's "from" header:

```ruby
Authenticate.configure do |config|
  config.mailer_sender = 'reply@example.com'
end
```


## Overriding Authenticate

### User Model

You can [use an alternate user model class](https://github.com/tomichj/authenticate/wiki/custom-user-model).


### Username Authentication

You can [authenticate with username](https://github.com/tomichj/authenticate/wiki/Authenticate-with-username).


### Routes

Authenticate adds routes to your application. See [config/routes.rb](/config/routes.rb) for the default routes.

If you want to control and customize the routes, you can turn off the built-in routes in
the Authenticate configuration with `config.routes = false` and dump a copy of the default routes into your
application for modification.

To turn off Authenticate's built-in routes:

```ruby
# config/initializers/authenticate.rb
Authenticate.configure do |config|
  config.routes = false
end
```

You can run a generator to dump a copy of the default routes into your application for modification. The generator
will also switch off the routes as shown immediately above by setting `config.routes = false`. 

```sh
$ rails generate authenticate:routes
```


### Controllers

If the customization at the views level is not enough, you can customize each controller, and the
authenticate mailer. See [app/controllers](/app/controllers) for the default controllers, and
[app/mailers](/app/mailers) for the default mailer.

To override an authenticate controller, subclass an authenticate controller and update your routes to point to it.

For example, to customize `Authenticate::SessionController`:

* subclass the controller:

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < Authenticate::SessionController
  # render sign in screen
  def new
    # ...
  end
end
```

* update your routes to use your new controller. 

Start by dumping a copy of authenticate routes to your `config/routes.rb`:

```sh
$ rails generate authenticate:routes 
```

Now update your routes to point to your new controller:

```ruby
# config/routes.rb
resource :sessions, controller: 'sessions', only: [:create, :new, :destroy]
```

You can also use the Authenticate controller generator to copy the default controllers and mailer into 
your application:

```sh
$ rails generate authenticate:controllers
```


### Views

You can quickly get started with a rails application using the built-in views. See [app/views](/app/views) for
the default views. When you want to customize an Authenticate view, create your own copy of it in your app.

You can use the Authenticate view generator to copy the default views into your application: 

```sh
$ rails generate authenticate:views
```


### Layout

Authenticate uses your application's default layout. If you would like to change the layout Authenticate uses when
rendering views, you can either deploy copies of the controllers and customize them, or you can specify
the layout in an initializer. This should be done in a to_prepare callback in `config/application.rb`
because it's executed once in production and before each request in development.
                              
You can specify the layout per-controller:

```ruby
config.to_prepare do
  Authenticate::PasswordsController.layout 'my_passwords_layout'
  Authenticate::SessionsController.layout 'my_sessions_layout'
  Authenticate::UsersController.layout 'my_users_layout'
end
```


### Translations

All flash messages and email lines are stored in i18n translations. You can override them like any other translation.

See [config/locales/authenticate.en.yml](/config/locales/authenticate.en.yml) for the default messages.


## Extending Authenticate

Authenticate can be extended via two mechanisms:

* user modules: add behavior to the user model
* callbacks: add rules or behavior during various authentication events, such as login and subsequent hits

Most of authenticate's behavior is implemented with a user module and a corresponding callback. User modules add 
behavior to the user, and the callback uses the user model data to decide an authentication attempt is valid or
invalid.


### User Modules

Add behavior to your User model for your callbacks to use. You can include behavior yourself directly
in your User class, but you can also use the Authenticate module loading system.

To add a custom module for Authenticate to load into your User model, e.g. `MyUserModule`:

```ruby
Authenticate.configuration do |config|
  config.modules = [MyUserModule]
end
```


### Callbacks

Callbacks can be added to Authenticate. Callbacks available at these points of the authenticate lifecycle:

- `Authenticate.lifecycle.after_set_user`
Runs with every hit requiring authentication. This includes both the initial authentication process and
subsequent to any controller secured by Authenticate. These callbacks run immediately after the User is determined. 
 
- `Authenticate.lifecycle.after_authentication`
These callbacks run only during the initial authentication process.

See [Lifecycle](lib/authenticate/lifecycle.rb) for full details.

Callbacks must `throw(:failure, message)` to signal an authentication/authorization failure. Callbacks can also perform
other actions on the user or session. Callbacks are invoked with `|user, session, options|`.

Here's a simple example that counts logins for users. It consists of a module for User implemented as an 
`ActiveSupport::Concern`, with a callback that is defined in an `included` block. The module and callback 
is added to the User module via the Authenticate configuration.

```ruby
# app/models/concerns/login_count.rb
module LoginCount
  extend ActiveSupport::Concern

  included do
    # Add a callback that is triggered after every authentication
    Authenticate.lifecycle.after_authentication name:'login counter' do |user, session, options|
      user.count_login if user
    end
  end

  def count_login
    self.login_count ||= 0
    self.login_count += 1
  end
end

# config/initializers/authenticate.rb
Authenticate.configuration do |config|
  config.modules = [LoginCount]
end
```

More complex callbacks and modules can be implemented in a separate file(s); in that case, 
the user module should `require` the callback file to inject it into Authenticate's callback lifecycle.


## Testing

### Feature/Integration/System Tests

Authenticate includes middleware which allows tests to directly sign a test user in,
eliminating the need to visit and submit the sign on form. This can significantly speeds up tests.
Used by integration, system, feature, etc tests.

Configure your test environment to enable the middleware:
```ruby
# config/environments/test.rb
MyRailsApp::Application.configure do
  # ...
  config.middleware.use Authenticate::Testing::IntegrationTestsSignOn
  # ...
end
```

Sign a test user in by passing as=USER_ID in a query parameter:
```ruby
visit root_path(as: user)
```

A feature spec using factory_girl and capybara with the integration sign on middleware might look like this: 
```ruby
require 'spec_helper'

feature 'dashboard' do
  scenario 'logged in user has name on dashboard' do
    user = create(:user)
    visit dashboard_path(as: user)
    expect(page).to have_content user.name
  end
end  
```


### Controller Tests

To test controller actions protected by authenticate with `before_action :require_login`, you can
use Authenticate's test helpers.

For `rspec`, add the following to your `spec/spec_helper.rb` or `spec/rails_helper.rb`:

```ruby
require 'authenticate/testing/rspec'
```

For `test-unit`, add the following to your `test/test_helper.rb`.

```ruby
require 'authenticate/testing/test_unit'
```

This will give you helper methods:

```ruby
login_as(user)
logout
```

Once you `login_as(user)`, you will satisfy the `require_login` filter. The other `Authenticate::Controller`
methods will then work: `current_user`, `logged_in?`, `logged_out?`

A controller spec using `factory_girl` and authenticate's controller helpers might look like this:
```ruby
require 'spec_helper'
describe DashboardsController do
  describe '#show' do
    it 'shows view' do
      user = create(:user)
      login_as(user)
      get :show
      expect(response).to be_success
      expect(response).to render_template 'dashboards/show'
    end
  end
end
```

Rails 5 built-in test suite's controller tests now extend `ActionDispatch::IntegrationTest`. Use the middleware 
`IntegrationTestsSignOn` to support sign on. For example:
```ruby
require 'test_helper'
class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test 'logged in user can GET a dashboard' do
    user = create(:user)
    get dashboards_show_path(as: user)
    assert_response :success
  end
end
```


### View Tests

For `rspec`, require `authenticate/testing/rspec` to include view helpers:

```ruby
login_as(user)
current_user
logged_in?
logged_out?
```

Once you `login_as(user)`, your view can make use of the other helpers as you'd expect. 

An example view spec using `factory_girl` and authenticate's view helpers:
```ruby
require 'spec_helper'
describe 'dashboards/show', type: :view do
  it 'displays user name' do
    user = create(:user)
    login_as(user)
    render
    expect(rendered).to match user.name  # view uses `current_user`
  end
end
```


## Additional Documentation

Consult the [Authenticate wiki](https://github.com/tomichj/authenticate/wiki/) for additional documentation.


## Versions of Rails Supported

Authenticate is tested with rails 4.2, 5.0, and 5.1.


## Changelog

For a summary of changes by version, see the [CHANGELOG.md](/CHANGELOG.md).


## License

Authenticate is copyright © 2015 Justin Tomich. It is free software, and may be
redistributed under the terms specified in the [`LICENSE`] file.

[`LICENSE`]: /LICENSE

