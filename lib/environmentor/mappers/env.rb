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

      def value_for_attribute(attr, **opts)
        k = attr_env_var_name(attr, **opts)

        if ENV.has_key?(k)
          ENV[k]
        else
          raise Environmentor::Mappers::ValueNotFound
        end
      end

      def human_description
        # TODO: localise
        "environment"
      end

      def human_attr_location(attr, **opts)
        attr_env_var_name attr, **opts
      end

    protected

      def attr_env_var_name(attr, name: nil, full_name: nil)
        k = full_name || (attr.namespace_chain.map { |s|
          self.class.opts_from_mappers_hash(s.opts)[:prefix] || s.name &&
            (s.name.to_s.upcase + '_')
        }.compact.join('') + (name || attr.name.to_s.upcase))

        k.prepend @prefix
      end

    end
  end
end
