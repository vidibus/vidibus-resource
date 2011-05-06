require "digest/md5"

module Vidibus::Resource
  module Provider
    module Mongoid
      extend ActiveSupport::Concern

      included do
        field :resource_consumers, :type => Array, :default => []
        field :resourceable_hash_checksum, :type => Hash

        before_update :update_resource_consumers
        before_destroy :destroy_resource_consumers
      end

      # Adds given resource consumer.
      def add_resource_consumer(service_uuid)
        list = resource_consumers || []
        list << service_uuid
        update_attributes(:resource_consumers => list.uniq)
      end

      # Removes given resource consumer.
      def remove_resource_consumer(service_uuid)
        self.resource_consumers.delete(service_uuid)
        save
      end

      def resource_provider?
        true
      end

      def resource_consumer?
        false
      end

      # TODO: Handle attributes properly
      def resourceable_hash
        attributes
      end

      # Fix empty arrays
      def fixed_resourceable_hash
        for key, value in resourceable_hash
          if value === []
            resourceable_hash[key] = [EMPTY_ARRAY_IDENTIFIER]
          end
        end
        resourceable_hash
      end

      private

      # Update resource consumers if significant changes were made.
      # TODO: Send changes only (the resourceable ones)!
      # TODO: Perform update asynchronously
      def update_resource_consumers
        return unless resource_consumers and resource_consumers.any?
        return unless changes.except("resource_consumers", "updated_at").any?

        hash = fixed_resourceable_hash
        hash_checksum = Digest::MD5.hexdigest(hash.to_s)
        unless hash_checksum == resourceable_hash_checksum
          self.resourceable_hash_checksum = hash_checksum
          for service in resource_consumers
            begin
              ::Service.discover(service, realm_uuid).put("/api/resources/#{self.class.to_s.tableize}/#{uuid}", :body => {:resource => hash})
            rescue => e
              Rails.logger.error "An error occurred while updating resource consumer #{service}:"
              Rails.logger.error e.inspect
            end
          end
        end
      end

      # Removes this resource from consumers.
      def destroy_resource_consumers
        for service in resource_consumers
          begin
            ::Service.discover(service, realm_uuid).delete("/api/resources/#{self.class.to_s.tableize}/#{uuid}")
          rescue => e
            Rails.logger.error "An error occurred while destroying resource consumer #{service}:"
            Rails.logger.error e.inspect
            errors = true
          end
        end
        true unless errors # ensure true!
      end
    end
  end
end
