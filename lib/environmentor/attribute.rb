require_relative 'type_coercer'

module Environmentor
  class Attribute

    class ValidationError < StandardError
      attr_reader :attr

      def initialize(attr, mappers, opts)
        @attr = attr
        @mappers = mappers
        @opts = opts
      end

      def message(msg = nil)
        decorate_msg(msg || "Validation error")
      end

      class Missing < ValidationError
        def message
          super "Couldn't find value"
        end
      end

    protected

      def decorate_msg(msg)
        msg << " for #{@attr.full_name}"
        msg << ", “#{@attr.description}”" if @attr.description
        msg << " (looked in " <<
          @mappers.map { |m|
            opts = m.class.opts_from_mappers_hash(@opts)
            "#{m.human_attr_location(@attr, **opts)} in #{m.human_description}"
          }.join(', ') <<
          ")"
      end

    end

    class ValidationErrors < Array
      alias_method :success?, :empty?
    end

    attr_reader :name, :type, :required, :default, :namespace_chain,
      :description
    attr_accessor :type_coercer

    def initialize(name, namespace_chain, type: :string, required: true, default: nil, description: nil, help: nil, mappers: {})
      raise ArgumentError, "#{type.inspect} isn't a valid type" unless type_coercer.valid_type?(type)
      @name = name
      @namespace_chain = namespace_chain
      @type = type
      @required = required
      @default = default
      @description = description || help
      @mappers_opts = mappers
    end

    alias :required? :required

    def full_name
      (namespace_chain.map(&:name).compact << name).join('.')
    end

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
      if required?
        raise ValidationError::Missing.new(self, mappers, @mappers_opts)
      end
      nil
    end

    def get_from_mapper(mapper, **opts)
      str_value = mapper.value_for_attribute(self, **opts) or return nil
      type_coercer.coerce_to(type, str_value)
    end

    def validate_in_mappers(mappers)
      ValidationErrors.new.tap do |out|
        if required?
          begin
            get_from_mappers(mappers)
          rescue ValidationError::Missing => e
            out << e
          end
        end
      end
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
