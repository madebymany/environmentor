require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

require 'environmentor'

module Environmentor
  class Schema
  protected
    def handle_attr_errors(*args)
      # no-op, otherwise it'll exit on us in the middle of a test.
    end
  end
end

