# Authenticate

A Rails authentication gem.

Authenticate is small, simple, but extensible. It has highly opinionated defaults but is
open to significant modification.

Authenticate is inspired by, and draws from, Devise, Warden, Authlogic, Clearance, Sorcery, and restful_authentication.

Please use [GitHub Issues] to report bugs.

[GitHub Issues]: https://github.com/tomichj/authenticate/issues

![Build status](https://travis-ci.org/tomichj/authenticate.svg?branch=master) ![Code Climate](https://codeclimate.com/github/tomichj/authenticate/badges/gpa.svg)

## Philosophy

* simple - Authenticate's code is straightforward and easy to read.
* opinionated - set the "right" defaults, but let you control almost everything if you want
* small footprint - as few public methods and modules as possible
* configuration driven - almost all configuration is performed in the initializer



## Implementation Overview

Authenticate:
* loads modules into your user model to provide authentication functionality
* loads `callbacks` that are triggered during authentication and access events. All authentication
decisions are performed in callbacks, e.g. do you have a valid session, has your session timed out, etc.
* loads a module into your controllers (typically application controller) to secure controller actions

The callback architecture is based on the system used by devise and warden, but significantly simplified.


### Session Token

Authenticate generates and clears a token (called a 'session token') to identify the user from a saved cookie.
When a user authenticates successfully, Authenticate generates and stores a 'session token' for your user in
your database. The session token is also stored in a cookie in the user's browser.
The cookie is then presented upon each subsequent access attempt to your server.

### User Model




## Install

To get started, add Authenticate to your `Gemfile`:

```ruby
gem 'authenticate'
```

Then run:

```sh
bundle install
```

Then run the installation generator:

```sh
rails generate authenticate:install
```

The generator does the following:

* Insert `include Authenticate::User` into your `User` model.
* Insert `include Authenticate::Controller` into your `ApplicationController`
* Add an initializer at `config/intializers/authenticate.rb`.
* Create migrations to either create a users table or add additional columns to :user. A primary migration is added,
'create users' or 'add_authenticate_to_users'. This migration is required. Two additonal migrations are created
to support the 'brute_force' and 'timeoutable' modules. You may delete the brute_force and timeoutable migrations,
but those migrations are required if you use those Authenticate features (see Configure, next).

Finally, you'll need to run the migrations that Authenticate just generated:

```sh
rake db:migrate
```


## Configure

Override any of these defaults in your application `config/initializers/authenticate.rb`.

```ruby
Authenticate.configure do |config|
  config.user_model = 'User'
  config.cookie_name = 'authenticate_session_token'
  config.cookie_expiration = { 1.year.from_now.utc }
  config.cookie_domain = nil
  config.cookie_path = '/
  config.secure_cookie = false
  config.http_only = false
  config.crypto_provider = Bcrypt
  config.timeout_in = nil  # 45.minutes
  config.max_session_lifetime = nil  # 8.hours
  config.max_consecutive_bad_logins_allowed = nil # 5
  config.bad_login_lockout_period = nil # 5.minutes
  config.authentication_strategy = :email
```

Configuration parameters are described in detail here: [Configuration](lib/authenticate/configuration.rb)


### timeout_in

* timeout_in: the interval to timeout the user session without activity.

If your configuration sets timeout_in to a non-nil value, then the last user access is tracked.
If the interval between the current access time and the last access time is greater than timeout_in,
the session is invalidated. The user will be prompted for authentication again.


### max_session_lifetime

* max_session_lifetime: the maximum interval a session is valid, regardless of user activity.

If your configuration sets max_session_lifetime, a User session will expire once it has been active for
max_session_lifetime. The user session is invalidated and the next access will will prompt the user for
authentication again.


### max_consecutive_bad_logins_allowed & bad_login_lockout_period

* max_consecutive_bad_logins_allowed: an integer
* bad_login_lockout_period: a ActiveSupport::CoreExtensions::Numeric::Time

To enable brute force protection, set max_consecutive_bad_logins_allowed to a non-nil positive integer.
The user's consecutive bad logins will be tracked, and if they exceed the allowed maximumm the user's account
will be locked. The lock will last `bad_login_lockout_period`, which can be any time period (e.g. `10.minutes`).


### authentication_strategy

The default authentication strategy is :email. This requires that your User model have an attribute named `email`.
The User account will be identified by this email address. The strategy will add email attribute validation to
the User, ensuring that it exists, is properly formatted, and is unique.

You may instead opt for :username. The username strategy will identify users with an attribute named `username`.
The strategy will also add username attribute validation, ensuring the username exists and is unique.



## Use

### Authentication

Authenticate provides a session controller and views to authenticate users. After successful authentication,
the user is redirected to the path they attempted to access, or as specified by the `redirect_url` property
 in your configuration. This defaults to '/' but can customized:

```ruby
Authenticate.configure do |config|
  config.redirect_url = '/specials'
end
```


### Access Control

Use the `require_authentication` filter to control access to controller actions.

```ruby
class ApplicationController < ActionController::Base
    before_action :require_authentication
end
```


### Helpers

Use `current_user` and `authenticated?` in controllers, views, and helpers.

Example:

```erb
<% if authenticated? %>
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


## Overriding Authenticate

### Views

You can quickly get started with a rails application using the built-in views. See [app/views](/app/views) for
the default views. When you want to customize an Authenticate view, create your own copy of it in your app.

You can use the Authenticate view generator to copy the default views into your application:

```sh
$ rails generate authenticate:views
```


### Controllers

If the customization at the views level is not enough, you can customize each controller, and the
authenticate mailer. See [app/controllers](/app/controllers) for the default controllers, and
[app/mailers](/app/mailers) for the default mailer.

You can use the Authenticate controller generator to copy the default controllers and mailer into your application:

```sh
$ rails generate authenticate:controllers
```


### Routes

Authenticate adds routes. See [config/routes.rb](/config/routes.rb) for the default routes.

If you want to control and customizer the routes, you can turn off the built-in routes in
the Authenticate configuration with `config.routes = false`.

You can optionally run a generator to dump a copy of the default routes into your application for modification.

```sh
$ rails generate authenticate:routes
```


## Extending Authenticate

Authenticate can be further extended with two mechanisms:

* user modules: add behavior to the user model
* callbacks: add behavior during various authentication events, such as login and subsequent hits


### User Modules

Add behavior to your User model for your callbacks to use. You can, of course, incldue behavrio yourself directly
in your User class, but you can also use the Authenticate module loading system.

To add a custom module to Authenticate, e.g. `MyUserModule`:

```ruby
Authenticate.configuration do |config|
  config.modules = [MyUserModule]
end
```


### Callbacks

Callbacks can be added to Authenticate. Use `Authenticate.lifecycle.after_set_user` or
`Authenticate.lifecycle.after_authentication`. See [Lifecycle](lib/authenticate/lifecycle.rb) for full details.

Callbacks can `throw(:failure, message)` to signal an authentication/authorization failure. Callbacks can also perform
actions on the user or session. Callbacks are passed a block at runtime of `|user, session, options|`.

Here's an example that counts logins for users. It consists of a module for User, and a callback that is
set in the `included` block. The callback is then added to the  User module via the Authenticate configuration.

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
    self.login_counter += 1
  end
end

# config/initializers/authenticate.rb
# You could also just `include LoginCount` in your user model.
Authenticate.configuration do |config|
  config.modules = [LoginCount]
end
```


## Testing

Authenticate has been tested with rails 4.2, other versions to follow.

## License

This project rocks and uses MIT-LICENSE.


