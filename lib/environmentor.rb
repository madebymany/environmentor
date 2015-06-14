require "environmentor/version"
require "environmentor/configurable"
require "environmentor/mappers/env"

module Environmentor
  extend self

  def new_mapper(sym, **opts)
    Environmentor::Mappers.new(sym, **opts)
  end

end
