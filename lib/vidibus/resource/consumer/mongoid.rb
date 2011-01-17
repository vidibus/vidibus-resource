module Vidibus::Resource
  module Consumer

    class ConfigurationError < StandardError; end

    module Mongoid
      extend ActiveSupport::Concern

      included do
        include Vidibus::Uuid::Mongoid

        field :resource_attributes, :type => Hash, :default => {}
        field :uuid
        index :uuid
        validates :uuid, :uuid => true

        before_create :add_resource_consumer
        before_save :set_resource_attributes
        before_destroy :remove_resource_consumer
      end

      # Registers this consumer with provider.
      def add_resource_consumer
        response = resource_provider.post("/api/resources/#{self.class.to_s.tableize}/#{uuid}")
        data = response["resource"]
        self.resource_attributes = fix_resource_attributes(data)
        set_resource_attributes(true)
        true # ensure true!
      end

      # Removes this consumer from provider.
      def remove_resource_consumer
        resource_provider.delete("/api/resources/#{self.class.to_s.tableize}/#{uuid}")
        true # ensure true!
      end

      # Updates resource attributes.
      # TODO: Update only data that has been changed.
      def update_resource_attributes(data)
        data = fix_resource_attributes(data)
        update_attributes(:resource_attributes => data)
      end

      # Returns a resource provider service.
      def resource_provider
        @resource_provider ||= begin
          service = self.class.instance_variable_get("@resource_provider") or
            raise ConfigurationError.new("No resource provider has been defined. Call #{self.class}.resource_provider(service, realm)")
          realm = self.class.instance_variable_get("@resource_realm") or
            raise ConfigurationError.new("No resource realm has been defined. Call #{self.class}.resource_realm(realm)")
          ::Service.discover(service, realm)
        end
      end

      protected

      # Populates attributes of instance from
      # received resource_attributes hash.
      def set_resource_attributes(force = false)
        if resource_attributes_changed? or force == true
          for key, value in resource_attributes
            send("#{key}=", value)
          end
        end
        true # ensure true!
      end

      # Defines attributes of resource_attributes hash as
      # methods on consumer instance.
      def method_missing(name, *args, &block)
        if name.to_s.match(/(.+)\=$/)
          writer = true
          attribute = $1
          name = "#{attribute}="
        else
          attribute = name.id2name
        end
        if resource_attributes and (value = resource_attributes[attribute])
          self.class.class_eval do
            field attribute.to_sym # Mongoid field
          end
          if writer
            send(name, *args)
          else
            send("#{attribute}=", value)
            send(name)
          end
        else
          super
        end
      end

      # Fix empty arrays
      def fix_resource_attributes(data)
        for key, value in data
          if value === [EMPTY_ARRAY_IDENTIFIER]
            data[key] = []
          end
        end
        data
      end

      module ClassMethods

        # Sets up resource provider service type and realm.
        def resource_provider(service, realm = nil)
          @resource_provider = service
          resource_realm(realm) if realm
        end

        # Sets up realm of resource.
        def resource_realm(realm)
          @resource_realm = realm
        end

        # Ensures that an instance with given conditions exists.
        def ensure!(conditions)
          self.where(conditions).first || self.create!(conditions)
        end

        # Remove all intances with given conditions.
        def remove(conditions)
          existing = self.where(conditions).to_a
          for instance in existing
            instance.destroy
          end
        end
      end
    end
  end
end
