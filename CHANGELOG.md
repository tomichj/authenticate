# Authenticate Changelog

## [0.4.0] - June 2, 2016

Install generator User:  ActiveRecord::Base for Rails 4 apps, ApplicationRecord for rails 5 (issue #2).

[0.4.0]: https://github.com/tomichj/authenticate/compare/v0.3.3...v0.4.0



## [0.3.3] - April 29, 2016

Password change uses active record's dirty bit to detect that password was updated. 
password_updated attribute removed.
spec_helper now calls ActiveRecord::Migration.maintain_test_schema! (or check_pending!) to handle dummy test db.
Added CodeClimate config.

[0.3.3]: https://github.com/tomichj/authenticate/compare/v0.3.2...v0.3.3



## [0.3.2] - April 28, 2016

Error now raised if User model is missing required attributes.
All code now conforms to a rubocode profile.

[0.3.2]: https://github.com/tomichj/authenticate/compare/v0.3.1...v0.3.2



## [0.3.1] - March 10, 2016

User controller now allows arbitrary parameters without having to explicitly declare
them. Still requires email and password.
Mailer now checks for mail.respond_to?(:deliver_later) rather than rails version, 
to decide deliver vs deliver_later.
Removed unused user_id_parameter config method.

[0.3.1]: https://github.com/tomichj/authenticate/compare/v0.3.0...v0.3.1



## [0.3.0] - February 24, 2016

Moved normalize_email and find_normalized_email methods to base User module.
Added full suite of controller and feature tests.
Bug fixes: 
* failed login count fix was off by one.
* password validation now done only in correct circumstances

[0.3.0]: https://github.com/tomichj/authenticate/compare/v0.2.2...v0.3.0



## [0.2.3] - February 13, 2016

Small bugfix for :username authentication.
Improved documentation, started adding wiki pages.

[0.2.3]: https://github.com/tomichj/authenticate/compare/v0.2.2...v0.2.3



## [0.2.2] - February 9, 2016

Password length range requirements added, defaults to 8..128.
Generators and app now respect model class more completely, including in routes.

[0.2.2]: https://github.com/tomichj/authenticate/compare/v0.2.1...v0.2.2



## [0.2.1] - February 9, 2016

Fixed potential password_reset nil pointer.
Continued adding I18n support.
Minor documentation improvments.

[0.2.1]: https://github.com/tomichj/authenticate/compare/v0.2.0...v0.2.1



## [0.2.0] - February 2, 2016

Added app/ including controllers, views, routes, mailers.

[0.2.0]: https://github.com/tomichj/authenticate/compare/v0.1.0...v0.2.0



## 0.1.0 - January 23, 2016

Initial Release, barely functioning

