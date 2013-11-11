module Vidibus::Resource
  module Consumer
    class ConsumerError < Error; end
    class ConfigurationError < ConsumerError; end

    module Mongoid
      extend ActiveSupport::Concern

      included do
        field :resource_attributes, :type => Hash, :default => {}
        field :resource_uuid
        field :uuid

        index({resource_uuid: 1})
        index({uuid: 1})

        validates :uuid, :uuid => true
        validates :resource_uuid, :uuid => {:allow_blank => true}

        attr_accessor :extinct

        before_create :add_resource_consumer, :unless => :resource_attributes?
        before_save :set_resource_attributes
        before_destroy :remove_resource_consumer, :unless => :extinct
      end

      # Registers this consumer with provider.
      def add_resource_consumer
        response = register_resource_consumer
        self.resource_attributes = JSON.parse(response['resource'])
        set_resource_attributes(true)
        true # ensure true!
      end

      # Removes this consumer from provider.
      def remove_resource_consumer
        resource_provider.delete(resource_uri)
        true # ensure true!
      end

      # Updates resource attributes from given JSON data.
      # TODO: Update only data that has been changed.
      def update_resource_attributes(json)
        update_attributes(:resource_attributes => JSON.parse(json))
      end

      # Returns a resource provider service.
      def resource_provider
        @resource_provider ||= begin
          service = self.class.instance_variable_get('@resource_provider') or
            raise ConfigurationError.new("No resource provider has been defined. Call #{self.class}.resource_provider(service, realm)")
          realm = (self.class.instance_variable_get('@resource_realm') || try!(:realm_uuid)) or
            raise ConfigurationError.new("No resource realm has been defined. Call #{self.class}.resource_realm(realm) or define the attribute :realm_uuid.")
          ::Service.discover(service, realm)
        end
      end

      def destroy_without_callback
        self.extinct = true
        destroy
      end

      module ClassMethods

        # Sets up resource provider service type and realm.
        def resource_provider(service, realm = nil)
          @resource_provider = service
          resource_realm(realm) if realm
        end

        # Sets up realm of resource.
        # If no realm has been set up class-wide, the attribute :realm_uuid will be used.
        def resource_realm(realm)
          @resource_realm = realm
        end

        # Ensures that an instance with given conditions exists.
        def ensure!(conditions)
          self.where(conditions).first || self.create!(conditions)
        end

        # Remove all instances with given conditions.
        def remove(conditions)
          existing = self.where(conditions).to_a
          for instance in existing
            instance.destroy
          end
        end
      end

      private

      # Populates attributes of instance from resource_attributes hash.
      def set_resource_attributes(force = false)
        if resource_attributes_changed? || new_record? || force == true
          resource_attributes.each do |key, value|
            meth = key.to_s

            unless respond_to?("#{meth}=")
              self.class.class_eval <<-END
                def #{meth}=(value)
                  self.write_attribute(:#{meth}, value)
                end
              END
            end

            unless respond_to?("#{meth}?")
              self.class.class_eval <<-END
                def #{meth}?
                  attr = read_attribute(:#{meth})
                  (attr === true) ? true : (attr === false) ? false : attr.present?
                end
              END
            end

            unless respond_to?(meth)
              self.class.class_eval <<-END
                def #{meth}
                  read_attribute(:#{meth})
                end
              END
            end

            send("#{meth}=", value)
          end
        end
        true # ensure true!
      end

      def register_resource_consumer
        resource_provider.post(resource_uri)
      end

      def resource_uri
        @resource_uri ||= "/api/resources/#{self.class.to_s.tableize}/#{resource_uuid || uuid}"
      end
    end
  end
end
