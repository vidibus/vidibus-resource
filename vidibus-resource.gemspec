# -*- encoding: utf-8 -*-
require File.expand_path("../lib/vidibus/resource/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "vidibus-resource"
  s.version     = Vidibus::Resource::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["André Pankratz"]
  s.email       = ["andre@vidibus.com"]
  s.homepage    = "http://github.com/vidibus/vidibus-resource"
  s.summary     = "Provides handling of remote resources"
  s.description = "Allows creation of proxy objects of remote resources on distributed applications."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "vidibus-resource"
  
  #s.add_dependency "rack", :git => "git://github.com/vidibus/rack.git"
  s.add_dependency "rails", "~> 3.0.0"
  s.add_dependency "vidibus-uuid"
  s.add_dependency "vidibus-service"
  s.add_dependency "vidibus-api"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rake", ">= 0"
  s.add_development_dependency "rspec", ">= 0"
  s.add_development_dependency "rack-test", ">= 0"
  s.add_development_dependency "rr", ">= 0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
