require_relative 'type_coercer'

module Environmentor
  class Attribute
    class RequiredValueNotFound < StandardError
      def initialize(attr)
        @attr = attr
      end

      def message
        "Couldn't find value for #{@attr.name}"
      end
    end

    attr_reader :name, :type, :required, :default
    attr_accessor :type_coercer

    def initialize(name, type: :string, required: true, default: nil, mappers: {})
      raise ArgumentError, "#{type.inspect} isn't a valid type" unless type_coercer.valid_type?(type)
      @name = name
      @type = type
      @required = required
      @default = default
      @mappers_opts = mappers
    end

    alias :required? :required

    def get_from_mappers(mappers)
      return @value if defined?(@value)

      mappers.each do |mapper|
        begin
          @value = get_from_mapper(
            mapper, **mapper.class.opts_from_mappers_hash(@mappers_opts))
        rescue Environmentor::Mappers::ValueNotFound
          next
        else
          return @value
        end
      end

      # TODO: better 'absent' value for default, so that a default can be nil?
      return default unless default.nil?
      raise RequiredValueNotFound, self if required
      nil
    end

    def get_from_mapper(mapper, **opts)
      str_value = mapper.value_for_attribute(self, **opts) or return nil
      type_coercer.coerce_string_to(type, str_value)
    end

    def check_exists_in_mappers!(mappers)
      get_from_mappers(mappers) if required?
    end

    def clear_cache!
      remove_instance_variable(:@value)
    end

  protected

    def self.type_coercer
      Environmentor::TypeCoercer
    end

    def type_coercer
      @type_coercer || self.class.type_coercer
    end

  end
end
