require_relative 'attribute'

module Environmentor
  class Schema

    attr_reader :attrs, :parent, :name, :opts

    def initialize(mappers, parent = nil, name = nil, **opts, &block)
      @parent = parent
      @name = name
      if parent && !name
        raise ArgumentError, "Namespace defined without name!"
      end

      @namespace_chain = build_namespace_chain
      @mappers = mappers
      @opts = opts
      @attrs = {}
      @schemas = []
      instance_exec(&block) if block_given?
    end

    def attr_config(name, **opts)
      (attrs[name] = Attribute.new(name, @namespace_chain, **opts)).tap do |attr|
        check_attr_exists! attr
      end
      nil
    end

    def namespace(name, &block)
      @schemas << Schema.new(@mappers, self, name, **@opts).tap { |s|
        s.instance_exec(&block)
      }
      nil
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

      @schemas.each do |s|
        next unless s.name
        ns_mod = Module.new
        s.map_to ns_mod

        mod.__send__(:define_method, s.name) do
          ns_mod
        end

        mod.__send__(:define_singleton_method, s.name) do
          ns_mod
        end
      end
    end

    def get_attr(attr)
      attr.get_from_mappers(@mappers)
    end

    def check_attr_exists!(attr)
      attr.check_exists_in_mappers!(@mappers)
    end

  private
    def build_namespace_chain
      s = self
      [].tap do |out|
        while s
          out.unshift s
          s = s.parent
        end
      end
    end
  end
end
