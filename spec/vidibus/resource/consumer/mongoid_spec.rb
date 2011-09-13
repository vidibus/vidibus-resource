require 'spec_helper'

describe Vidibus::Resource::Consumer::Mongoid do
  describe 'resource attributes' do
    let(:subject) do
      ConsumerModel.new.tap do |m|
        m.resource_attributes = {'name' => 'Jenny'}
        m.send(:set_resource_attributes, true)
      end
    end

    it 'should be readable' do
      subject.name.should eql('Jenny')
    end

    it 'should be writable' do
      subject.name = 'Sara'
      subject.name.should eql('Sara')
    end

    it 'should be persistent' do
      stub(subject).add_resource_consumer
      stub(subject).set_resource_attributes
      subject.save
      subject.update_attributes!({:name => 'Sara'})
      subject.reload
      subject.name.should eql('Sara')
    end
  end

  describe '#add_resource_consumer' do
    it 'should be spec\'d'
  end
end