require_relative 'environmentor/version'
require_relative 'environmentor/configurable'
require_relative 'environmentor/mappers'

module Environmentor
  extend self

  def new_mapper(sym, **opts)
    Environmentor::Mappers.new(sym, **opts)
  end

end
