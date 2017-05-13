$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'authenticate/version'
require 'date'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'authenticate'
  s.version     = Authenticate::VERSION
  s.authors     = ['Justin Tomich']
  s.email       = ['justin@tomich.org']
  s.homepage    = 'http://github.com/tomichj/authenticate'
  s.summary     = 'Authentication for Rails applications'
  s.description = 'Authentication for Rails applications'
  s.license     = 'MIT'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec}/*`.split("\n")

  s.require_paths = ['lib']
  s.extra_rdoc_files = %w(LICENSE README.md CHANGELOG.md)
  s.rdoc_options = ['--charset=UTF-8']

  s.add_dependency 'bcrypt'
  s.add_dependency 'email_validator', '~> 1.6'
  s.add_dependency 'rails', '>= 4.0', '< 5.2'

  s.add_development_dependency 'factory_girl', '~> 4.8'
  s.add_development_dependency 'rspec-rails', '~> 3.6'
  s.add_development_dependency 'pry', '~> 0.10'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'shoulda-matchers', '~> 2.8'
  s.add_development_dependency 'capybara', '~> 2.14'
  s.add_development_dependency 'database_cleaner', '~> 1.5'
  s.add_development_dependency 'timecop', '~> 0.8'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'rake'

  s.required_ruby_version = Gem::Requirement.new('>= 2.0')
end
