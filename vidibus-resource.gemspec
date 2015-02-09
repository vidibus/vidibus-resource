# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'vidibus/resource/version'

Gem::Specification.new do |s|
  s.name        = 'vidibus-resource'
  s.version     = Vidibus::Resource::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = 'Andre Pankratz'
  s.email       = 'andre@vidibus.com'
  s.homepage    = 'https://github.com/vidibus/vidibus-resource'
  s.summary     = 'Provides handling of remote resources'
  s.description = 'Allows creation of proxy objects of remote resources on distributed applications.'
  s.license = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'vidibus-resource'

  s.add_dependency 'activesupport', '>= 3'
  s.add_dependency 'mongoid', '~> 3'
  s.add_dependency 'json'
  s.add_dependency 'vidibus-uuid'
  s.add_dependency 'vidibus-service', '~> 0.3'
  s.add_dependency 'vidibus-api'
  s.add_dependency 'delayed_job', '~> 3'
  s.add_dependency 'delayed_job_mongoid'

  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'

  s.files = Dir.glob('{lib,app,config}/**/*') + %w[LICENSE README.md Rakefile]
  s.require_path = 'lib'
end
