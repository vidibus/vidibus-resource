require "rails"
require "vidibus-uuid"
require "vidibus-secure"
require "vidibus-api"

$:.unshift(File.join(File.dirname(__FILE__), "vidibus"))
require "resource"

module Vidibus::Resource
  class Engine < ::Rails::Engine; end
end
