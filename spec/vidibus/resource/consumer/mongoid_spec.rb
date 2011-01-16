require "spec_helper"

class Model
  include Mongoid::Document
  include Vidibus::Resource::Consumer::Mongoid
end

describe "Vidibus::Resource::Consumer::Mongoid" do

  let(:model) do
    Model.new.tap do |m|
      m.resource_attributes = {"name" => "Jenny"}
    end
  end

  describe "attributes" do
    it "should be readable" do
      model.name.should eql("Jenny")
    end

    it "should be writable" do
      model.name = "Sara"
      model.name.should eql("Sara")
    end

    it "should be persistent" do
      stub(model).add_resource_consumer
      stub(model).set_resource_attributes
      model.save
      model.update_attributes!({:name => "Sara"})
      model.reload
      model.name.should eql("Sara")
    end
  end
end