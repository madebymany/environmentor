require_relative 'mappers'
require_relative 'schema'

module Environmentor
  class ConfigManager

    attr_reader :schemas

    def initialize(mod)
      @mod = mod
      @schemas = []
    end

    def with_mapper(mappers, **opts, &block)
      defined_at = caller.first
      mappers = Array(mappers).
        map { |m| Environmentor::Mappers.deduce(m, **opts) }.
        compact

      Schema.new(mappers, defined_at: defined_at, **opts, &block).tap do |s|
        s.map_to @mod
        @schemas << s
      end
    end

    def delegate_to(mod)
      mod.environmentor.schemas.each do |s|
        s.map_to @mod
      end
    end

    alias :with_mappers :with_mapper
  end
end
