module Environmentor
  module Mappers
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

      def human_description
        raise NotImplementedError
      end

      def human_attr_location(attr)
        raise NotImplementedError
      end

    end
  end
end

