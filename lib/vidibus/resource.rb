module Vidibus
  module Resource
    EMPTY_ARRAY_IDENTIFIER = "__r::array__"
  end
end

require "vidibus/resource/provider/mongoid"
require "vidibus/resource/consumer/mongoid"
