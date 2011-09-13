require "json"
require "rails"
require "delayed_job"
require "delayed_job_mongoid"
require "vidibus-uuid"
require "vidibus-secure"
require "vidibus-api"
require "vidibus-service"

require "vidibus/resource"

module Vidibus::Resource
  class Engine < ::Rails::Engine; end
end
