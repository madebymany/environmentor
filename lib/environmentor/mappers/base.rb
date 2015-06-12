module Environmentor
  module Mappers
    class ValueNotFound < StandardError; end

    class Base
      Names = {}

      def self.singleton_method_added(n)
        # Yuck, sorry.
        if n == :to_sym
          Environmentor::Mappers::Base::Names[to_sym] = self
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

