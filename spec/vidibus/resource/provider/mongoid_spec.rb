require 'spec_helper'

describe Vidibus::Resource::Provider::Mongoid do
  let(:subject) do
    ProviderModel.create(:name => 'Jenny', :uuid => '84e8a690b6e1012e744a6c626d58b44c')
  end

  describe 'updating' do
    context 'without registered consumers' do
      it 'should update the record' do
        subject.update_attributes(:name => 'Marta').should be_true
        subject.reload.name.should eq('Marta')
      end
    end

    context 'with registered consumers' do
      before do
        subject.add_resource_consumer(consumer.uuid, realm_uuid)
        subject.add_resource_consumer(another_consumer.uuid, realm_uuid)
      end

      it 'should update the record' do
        subject.update_attributes(:name => 'Marta').should be_true
        subject.reload.name.should eq('Marta')
      end

      it 'should update each service' do
        mock(subject).update_resource_consumer(consumer.uuid, realm_uuid)
        mock(subject).update_resource_consumer(another_consumer.uuid, realm_uuid)
        subject.update_attributes(:name => 'Marta').should be_true
      end
    end
  end

  describe 'destroying' do
    context 'without registered consumers' do
      it 'should destroy the record' do
        subject.destroy.should be_true
        expect {subject.reload}.to raise_error
      end
    end

    context 'with registered consumers' do
      before do
        subject.add_resource_consumer(consumer.uuid, realm_uuid)
        subject.add_resource_consumer(another_consumer.uuid, realm_uuid)
      end

      it 'should destroy the record' do
        subject.destroy.should be_true
        expect {subject.reload}.to raise_error
      end

      it 'should remove the resource from all consumer services' do
        mock(subject).destroy_resource_consumer(consumer.uuid, realm_uuid)
        mock(subject).destroy_resource_consumer(another_consumer.uuid, realm_uuid)
        subject.destroy
      end
    end
  end

  describe '#add_resource_consumer' do
    before {stub_services}

    it 'should register a service as consumer' do
      stub(subject).update_resource_consumer(consumer.uuid, realm_uuid)
      subject.add_resource_consumer(consumer.uuid, realm_uuid)
      subject.resource_consumers.should have(1).resource_consumer
    end

    it 'should update the consumer service asynchronously' do
      subject.add_resource_consumer(consumer.uuid, realm_uuid)
      Delayed::Backend::Mongoid::Job.count.should eq(1)
    end

    it 'should send an API request to the consumer service' do
      stub_request(:post, "#{consumer.url}/api/resources/provider_models/#{subject.uuid}").
        with(:body => {:resource => JSON.generate(subject.resourceable_hash), :realm => realm_uuid, :service => this.uuid, :sign => '1b39337f4dee30a15bed7651cf8749b6efb60d71c434160f301f1e72545f3886'}).
          to_return(:status => 200, :body => "", :headers => {})
      subject.add_resource_consumer(consumer.uuid, realm_uuid)
      Delayed::Backend::Mongoid::Job.first.invoke_job
    end

    context 'with an existing consumer service' do
      before do
        subject.add_resource_consumer(another_consumer.uuid, realm_uuid)
      end

      it 'should do nothing if consumer has already been added' do
        dont_allow(subject).update_resource_consumer.with_any_args
        subject.add_resource_consumer(another_consumer.uuid, realm_uuid)
      end

      it 'should not update existing consumers' do
        dont_allow(subject).update_resource_consumer(another_consumer.uuid, realm_uuid)
        stub(subject).update_resource_consumer(consumer.uuid, realm_uuid)
        subject.add_resource_consumer(consumer.uuid, realm_uuid)
      end
    end
  end

  describe '#remove_resource_consumer' do
    before do
      stub(subject).create_resource_consumer.with_any_args
      subject.add_resource_consumer(consumer.uuid, realm_uuid)
    end

    it 'should remove the service with matching uuid and realm' do
      subject.remove_resource_consumer(consumer.uuid, realm_uuid)
      subject.resource_consumers.count.should eq(0)
    end

    it 'should be persistent' do
      subject.remove_resource_consumer(consumer.uuid, realm_uuid)
      subject.reload.resource_consumers.count.should eq(0)
    end

    it 'should not remove other services' do
      subject.add_resource_consumer(another_consumer.uuid, realm_uuid)
      subject.remove_resource_consumer(consumer.uuid, realm_uuid)
      subject.resource_consumers.count.should eq(1)
    end

    it 'should raise an error if no service with given uuid and realm has been added' do
      expect {subject.remove_resource_consumer(consumer.uuid, '289e0df0219f012e52fb6c626d58b44c')}.to raise_error(Vidibus::Resource::Provider::ConsumerNotFoundError)
    end

    it 'should delete the consumer service asynchronously' do
      subject.remove_resource_consumer(consumer.uuid, realm_uuid)
      Delayed::Backend::Mongoid::Job.count.should eq(1)
    end

    it 'should send an API request to the consumer service' do
      stub_request(:delete, "#{consumer.url}/api/resources/provider_models/#{subject.uuid}").
        with(:query => {:realm => realm_uuid, :service => this.uuid, :sign => 'fd1daf5fc585b092835971a39325d533c0e76083c6d51ec2facbe35c694bef06'}).
          to_return(:status => 200, :body => "", :headers => {})
      subject.remove_resource_consumer(consumer.uuid, realm_uuid)
      Delayed::Backend::Mongoid::Job.first.invoke_job
    end
  end

  describe '#resourceable_hash' do
    it 'should work without arguments' do
      subject.resourceable_hash.should eq({
        'name' => 'Jenny', 'uuid' => '84e8a690b6e1012e744a6c626d58b44c'
      })
    end

    it 'should work with 2 arguments' do
      subject.resourceable_hash('a', 'b').should eq({
        'name' => 'Jenny', 'uuid' => '84e8a690b6e1012e744a6c626d58b44c'
      })
    end
  end

  describe '.consumers_in_realm' do
    before do
      stub(subject).create_resource_consumer.with_any_args
    end

    it 'should return resources of a given realm' do
      subject.add_resource_consumer(consumer.uuid, realm_uuid)
      ProviderModel.consumers_in_realm(realm_uuid).count.should eq(1)
    end

    it 'should not return resources of other realms' do
      subject.add_resource_consumer(consumer.uuid, '289e0df0219f012e52fb6c626d58b44c')
      ProviderModel.consumers_in_realm(realm_uuid).count.should eq(0)
    end
  end
end
