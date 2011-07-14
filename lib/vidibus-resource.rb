require "rails"
require "vidibus-uuid"
require "vidibus-secure"
require "vidibus-api"

require "vidibus/resource"

module Vidibus::Resource
  class Engine < ::Rails::Engine; end
end
