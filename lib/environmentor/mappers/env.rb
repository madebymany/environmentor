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
        k = full_name || (attr.namespace_chain.map { |s|
          self.class.opts_from_mappers_hash(s.opts)[:prefix] || s.name &&
            (s.name.to_s.upcase + '_')
        }.compact.join('') + (name || attr.name.to_s.upcase))

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
