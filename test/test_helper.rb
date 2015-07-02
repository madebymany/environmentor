require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!
require 'wrong'
require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  at_exit do
    files = SimpleCov.result.files.select { |f| f.covered_percent < 100 }
    next if files.empty?

    puts "\n*** Tests do not have 100% coverage ***"
    files.sort_by!(&:covered_percent)
    files.each do |f|
      puts "%.2f%%: " % f.covered_percent << f.filename
    end
    puts
    SimpleCov.result.format!
    puts
  end
end

class MiniTest::Test
  # Copy/paste from the Wrong adapter cos I can't get it to work somehow?

  include Wrong::Assert
  include Wrong::Helpers

  def failure_class
    MiniTest::Assertion
  end

  def minitest_assertion_count
    self.assertions
  end

  def minitest_increment_assertions
    self.assertions += 1
  end

  def aver(valence, explanation = nil, depth = 0)
    minitest_increment_assertions
    super(valence, explanation, depth + 1) # apparently this passes along the default block
  end
end

require_relative 'env_vars'

require 'environmentor'

module Environmentor
  class Schema
  protected
    def handle_attr_errors(*args)
      # no-op, otherwise it'll exit on us in the middle of a test.
    end
  end
end

