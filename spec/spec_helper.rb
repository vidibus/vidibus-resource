$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "rubygems"
require "rspec"
require "rack/test"
require "rr"
require "webmock/rspec"
require "vidibus-resource"

Mongoid.configure do |config|
  name = "vidibus-resource_test"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  config.logger = nil
end

RSpec.configure do |config|
  config.include WebMock
  config.mock_with :rr
  config.before(:each) do
    Mongoid.master.collections.select {|c| c.name !~ /system/}.each(&:drop)
  end
end
