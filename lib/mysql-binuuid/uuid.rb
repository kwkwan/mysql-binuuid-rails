require 'uuidtools'

module MySQLBinUUID
  module UUID
    extend ActiveSupport::Concern

    included do
      class_attribute :_natural_key, instance_writer: false
      class_attribute :_uuid_namespace, instance_writer: false
      class_attribute :_uuid_generator, instance_writer: false
      self._uuid_generator = :random

      before_create :generate_uuids_if_needed
    end

    module ClassMethods
      def natural_key(*attributes)
        self._natural_key = attributes
      end

      def uuid_namespace(namespace)
        namespace = UUIDTools::UUID.parse_string(namespace) unless namespace.is_a? UUIDTools::UUID
        self._uuid_namespace = namespace
      end

      def uuid_generator(generator_name)
        self._uuid_generator = generator_name
      end
    end

    def create_uuid
      uuid = if _natural_key
              # TODO if all the attributes return nil you might want to warn about this
              chained = _natural_key.map { |attribute| self.send(attribute) }.join('-')
              UUIDTools::UUID.sha1_create(_uuid_namespace || UUIDTools::UUID_OID_NAMESPACE, chained)
            else
              case _uuid_generator
              when :random
                UUIDTools::UUID.random_create
              when :time
                UUIDTools::UUID.timestamp_create
              end
            end
      uuid.to_s
    end

    def generate_uuids_if_needed
      primary_key = self.class.primary_key
      if self.class.columns_hash[primary_key].type == :binary
        send("#{primary_key}=", create_uuid) unless send("#{primary_key}?")
      end
    end

  end
end
