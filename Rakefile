require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'appraisal'

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'
require 'rspec/core/rake_task'

namespace :dummy do
  require_relative "spec/dummy/config/application"
  Dummy::Application.load_tasks
end

RSpec::Core::RakeTask.new(:spec)

desc 'Run all specs in spec directory (excluding plugin specs)'
task default: :spec

task :build do
  system "gem build authenticate.gemspec"
end

task release: :build do
  system "gem push authenticate-#{Authenticate::VERSION}"
end
