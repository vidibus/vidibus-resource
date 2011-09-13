require 'rspec'
require 'mongoid'
require 'rack/test'
require 'rr'
require 'webmock/rspec'
require 'vidibus-resource'


Mongoid.configure do |config|
  name = 'vidibus-resource_test'
  host = 'localhost'
  # config.master = Mongo::Connection.new("localhost", 27017, :logger => Logger.new($stdout, :info)).db(name)
  config.master = Mongo::Connection.new.db(name)
  config.logger = nil
end

RSpec.configure do |config|
  config.mock_with :rr
  config.before(:each) do
    Mongoid.master.collections.select {|c| c.name !~ /system/}.each(&:drop)
  end
end
