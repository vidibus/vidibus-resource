module Vidibus
  module Resource
    EMPTY_ARRAY_IDENTIFIER = "__r::array__"
  end
end

require "resource/provider/mongoid"
require "resource/consumer/mongoid"
