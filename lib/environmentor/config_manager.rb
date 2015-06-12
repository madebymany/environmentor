require_relative 'schema'

module Environmentor
  class ConfigManager

    attr_reader :schemas

    def initialize(mod)
      @mod = mod
      @schemas = []
    end

    def with_mapper(mappers, **opts, &block)
      mappers = Array(mappers)
      mappers.map! { |m|
        case m
        when Environmentor::Mappers::Base
          m
        when Symbol, String
          Environmentor::Mappers::Base::Names.fetch(m.to_sym).new
        else
          raise "#{m.inspect} is not a recognised mapper"
        end
      }
      mappers.compact!

      s = Schema.new(mappers, **opts, &block)
      s.map_to @mod
      @schemas << s
      nil
    end

    def delegate_to(mod)
      mod.environmentor.schemas.each do |s|
        s.map_to @mod
      end
    end

    alias :with_mappers :with_mapper
  end
end
