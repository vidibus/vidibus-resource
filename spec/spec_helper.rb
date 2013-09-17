require 'rspec'
require 'mongoid'
require 'rr'
require 'webmock/rspec'
require 'vidibus-resource'

require 'support/models'
require 'support/services'

Mongoid.configure do |config|
  config.connect_to('vidibus-resource_test')
end

RSpec.configure do |config|
  config.include WebMock::API
  config.mock_with :rr
  config.before(:each) do
    Mongoid::Sessions.default.collections.
      select {|c| c.name !~ /system/}.each(&:drop)
  end
end
