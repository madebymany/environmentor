require_relative 'attribute'

module Environmentor
  class Schema

    attr_reader :attrs

    def initialize(mappers, **opts, &block)
      @mappers = mappers
      @attrs = {}
      instance_exec(&block) if block_given?
    end

    def attr_config(name, **opts)
      (attrs[name] = Attribute.new(name, **opts)).tap do |attr|
        check_attr_exists! attr
      end
    end

    def map_to(mod)
      schema = self
      attrs.each do |name, attr|
        mod.__send__(:define_method, name) do
          schema.get_attr attr
        end

        mod.__send__(:define_singleton_method, name) do
          schema.get_attr attr
        end
      end
    end

    def get_attr(attr)
      attr.get_from_mappers(@mappers)
    end

    def check_attr_exists!(attr)
      attr.check_exists_in_mappers!(@mappers)
    end
  end
end
