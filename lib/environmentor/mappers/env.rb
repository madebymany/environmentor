require_relative 'base'

module Environmentor
  module Mappers
    class Env < Base

      def self.to_sym
        :env
      end

      def initialize(prefix: '')
        @prefix = prefix
      end

      def value_for_attribute(attr, name: nil, full_name: nil)
        k = if name
              # TODO: namespacing
              name
            elsif full_name
              full_name
            else
              attr.name.to_s.upcase
            end
        k.prepend @prefix

        if ENV.has_key?(k)
          ENV[k]
        else
          raise Environmentor::Mappers::ValueNotFound
        end
      end

    end
  end
end
