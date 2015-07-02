require_relative 'attribute'

module Environmentor
  class Schema

    attr_accessor :defined_at
    attr_reader :attrs, :parent, :name, :opts, :children

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
      @children = []
      @defined_at = opts[:defined_at] || caller.first

      if block_given?
        instance_exec(&block)
        validate!
      end
    end

    def attr_config(name, **opts)
      attrs[name] = Attribute.new(name, @namespace_chain, **opts)
      nil
    end

    def namespace(name, &block)
      opts = @opts.merge(defined_at: caller.first)
      @children << Schema.new(@mappers, self, name, **opts).tap { |s|
        s.instance_exec(&block)
      }
      nil
    end

    def validate
      Attribute::ValidationErrors.new.tap do |errors|
        attrs.each do |_, attr|
          errors.concat validate_attr(attr)
        end

        @children.each do |schema|
          errors.concat schema.validate
        end
      end
    end

    def validate!
      validate.tap do |errors|
        handle_attr_errors(errors) unless errors.success?
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

      @children.each do |s|
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

  protected

    def validate_attr(attr)
      attr.validate_in_mappers(@mappers)
    end

    # :nocov:
    def handle_attr_errors(errors)
      # TODO: maybe make customisable somehow. At least this is overridable
      # in isolation.
      puts "#{$0}: fatal: failed to validate external config defined at"
      puts defined_at << ":"
      errors.each do |e|
        puts "* " << e.message
      end
      exit 1
    end
    # :nocov:

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
