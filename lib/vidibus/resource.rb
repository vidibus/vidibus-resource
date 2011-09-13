module Vidibus
  module Resource
    class Error < StandardError; end
  end
end

require "vidibus/resource/provider/mongoid"
require "vidibus/resource/consumer/mongoid"
