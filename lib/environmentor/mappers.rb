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
  end
end

Dir[File.expand_path('../mappers/*.rb', __FILE__)].each do |fn|
  require fn
end
