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
  s.summary     = 'Rails authentication with email & password'
  s.description = 'Rails authentication with email & password'
  s.license     = 'MIT'

  # s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.files = `git ls-files`.split("\n")
  # s.test_files = `git ls-files -- {spec}/*`.split("\n")
  s.test_files = Dir['spec/**/*_spec.rb']

  s.extra_rdoc_files = %w(LICENSE README.md)
  s.rdoc_options = ['--charset=UTF-8']

  s.require_paths = ['lib']

  s.add_dependency 'bcrypt'
  s.add_dependency 'email_validator', '~> 1.6'
  s.add_dependency 'rails', '>= 4.0', '< 5.1'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  # s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'pry'

  s.required_ruby_version = Gem::Requirement.new('>= 2.0')
end
