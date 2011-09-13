require 'digest/md5'

module Vidibus::Resource
  module Provider
    class ProviderError < Error; end
    class ServiceError < ProviderError; end
    class ConsumerNotFoundError < ProviderError; end

    module Mongoid
      extend ActiveSupport::Concern

      included do
        field :resource_consumers, :type => Hash, :default => {}
        field :resourceable_hash_checksum, :type => Hash

        before_update :update_resource_consumers
        before_destroy :destroy_resource_consumers

        scope :consumers_in_realm, lambda {|realm| where("resource_consumers.#{realm_uuid}" => {'$exists' => true})}
      end

      # Adds given resource consumer.
      def add_resource_consumer(service_uuid, realm_uuid)
        self.resource_consumers ||= {}
        self.resource_consumers[realm_uuid] ||= []
        unless resource_consumers[realm_uuid].include?(service_uuid)
          self.resource_consumers[realm_uuid] << service_uuid
          create_resource_consumer(service_uuid, realm_uuid)
          save
        end
      end

      # Removes given resource consumer.
      def remove_resource_consumer(service_uuid, realm_uuid)
        unless resource_consumers[realm_uuid] and resource_consumers[realm_uuid].include?(service_uuid)
          raise(ConsumerNotFoundError, "This resource has no consumer #{service_uuid} within realm #{realm_uuid}.")
        end
        destroy_resource_consumer(service_uuid, realm_uuid)
        self.resource_consumers[realm_uuid].delete(service_uuid)
        self.resource_consumers.delete(realm_uuid) if resource_consumers[realm_uuid].blank?
        save
      end

      # TODO: Get rid of this! It's only for the controller...
      def resource_provider?
        true
      end

      # TODO: Get rid of this! It's only for the controller...
      def resource_consumer?
        false
      end

      def resourceable_hash
        @resourceable_hash ||= attributes.except('resource_consumers', '_id')
      end

      def resourceable_hash_json
        @resourceable_hash_json ||= JSON.generate(resourceable_hash)
      end

      private

      def resource_uri
        @resource_uri ||= "/api/resources/#{self.class.to_s.tableize}/#{uuid}"
      end

      # Performs given block on each resource consumer service.
      def each_resource_consumer
        resource_consumers.each do |realm_uuid, service_uuids|
          service_uuids.each do |service_uuid|
            yield(service_uuid, realm_uuid)
          end
        end
      end

      # Updates resource consumers if significant changes were made.
      # TODO: Send changes only (the resourceable ones)!
      # Performs update asynchronously.
      def update_resource_consumers
        return unless resource_consumers and resource_consumers.any?
        return unless changes.except('resource_consumers', 'updated_at').any?

        self.resourceable_hash_checksum = Digest::MD5.hexdigest(resourceable_hash_json)
        if resourceable_hash_checksum_changed?
          each_resource_consumer do |service_uuid, realm_uuid|
            update_resource_consumer(service_uuid, realm_uuid)
          end
        end
      end

      # Removes this resource from consumers.
      # Performs update asynchronously.
      def destroy_resource_consumers
        each_resource_consumer do |service_uuid, realm_uuid|
          destroy_resource_consumer(service_uuid, realm_uuid)
        end
      end

      # Sends an API request to create the resource consumer.
      def create_resource_consumer(service_uuid, realm_uuid)
        resource_consumer_request(service_uuid, realm_uuid, :post, :body => {:resource => resourceable_hash_json})
      end

      # Sends an API request to update the resource consumer.
      def update_resource_consumer(service_uuid, realm_uuid)
        resource_consumer_request(service_uuid, realm_uuid, :put, :body => {:resource => resourceable_hash_json})
      end

      # Sends an API request to delete the resource consumer.
      def destroy_resource_consumer(service_uuid, realm_uuid)
        resource_consumer_request(service_uuid, realm_uuid, :delete)
      end

      def resource_consumer_request(service_uuid, realm_uuid, method, options = {})
        begin
          ::Service.discover(service_uuid, realm_uuid).delay.send(method, resource_uri, options)
        rescue => e
          raise(ServiceError, "Sending a #{method} request to the resource consumer #{service_uuid} within realm #{realm_uuid} failed!\n#{e.inspect}")
        end
      end
    end
  end
end
