module Environmentor
  module Mappers
    class ValueNotFound < StandardError; end

    Names = {}

    def self.new(sym, **opts)
      class_from_sym!(sym.to_sym).new(**opts)
    end

    def self.class_from_sym(sym)
      Names[sym]
    end

    def self.class_from_sym!(sym)
      Names.fetch(sym)
    end

    def self.register(sym, obj)
      Names[sym.to_sym] = obj
    end

    def self.deduce(m, **opts)
      case m
      when Environmentor::Mappers::Base
        m
      when Symbol, String
        Environmentor.new_mapper(m.to_sym, **opts)
      else
        raise "#{m.inspect} is not a recognised mapper"
      end
    end

    class Base

      def self.singleton_method_added(n)
        # Yuck, sorry.
        if n == :to_sym
          Environmentor::Mappers.register(to_sym, self)
        end
        super
      end

      def self.opts_from_mappers_hash(h)
        if respond_to?(:to_sym)
          h[to_sym] || {}
        else
          {}
        end
      end

      def initialize(**opts)
        @opts = opts
      end

      def value_for_attribute(attr, **opts)
        raise NotImplementedError
      end
    end
  end
end

