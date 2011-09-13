class Service
  include Mongoid::Document
  include Vidibus::Service::Mongoid
end

def realm_uuid
  @realm_uuid ||= '7d4ef7d0974a012d10ad58b035f038ab'
end

def this
  @this ||= Service.create!(:function => 'manager', :url => 'http://manager.local',
    :uuid => '344b4b8088fb012dd3e558b035f038ab', :secret => 'EaDai5nz16DbQTWQuuFdd4WcAiZYRPDwZTn2IQeXbPE4yBg3rr',
    :realm_uuid => nil, :this => true)
end

def connector
  @connector ||= Service.create!(:function => 'connector', :url => 'http://connector.local',
    :uuid => '60dfef509a8e012d599558b035f038ab', :secret => nil,
    :realm_uuid => nil)
end

def consumer
  @consumer ||= Service.create!(:function => 'user', :url => 'http://consumer.local',
    :uuid => 'c0861d609247012d0a8b58b035f038ab', :secret => 'A7q8Vzxgrk9xrw2FCnvV4bv01UP/LBUUM0lIGDmMcB2GsBTIqx',
    :realm_uuid => realm_uuid)
end

def another_consumer
  @another_consumer ||= Service.create!(:function => 'user', :url => 'http://another.consumer.local',
    :uuid => '6062e8d0b2d3012e739e6c626d58b44c', :secret => 'B7q8Vzxgrk9xrw2FCnvV4bv01UP/LBUUM0lIGDmMcB2GsBTIqx',
    :realm_uuid => realm_uuid)
end

def stub_services
  connector; this; consumer
end
