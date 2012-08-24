require "json"
require "delayed_job"
require "delayed_job_mongoid"
require "vidibus-uuid"
require "vidibus-secure"
require "vidibus-api"
require "vidibus-service"

require "vidibus/resource"

if defined?(::Rails)
  module Vidibus::Resource
    class Engine < ::Rails::Engine; end
  end
end
