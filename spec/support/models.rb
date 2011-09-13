class ProviderModel
  include Mongoid::Document
  include Vidibus::Uuid::Mongoid
  include Vidibus::Resource::Provider::Mongoid
  field :name, :type => String
end

class ConsumerModel
  include Mongoid::Document
  include Vidibus::Uuid::Mongoid
  include Vidibus::Resource::Consumer::Mongoid
end
