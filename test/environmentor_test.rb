require 'test_helper'

ENV['TEST_VALUE'] = "hello"
ENV['INT_VALUE'] = "42"
ENV['BOOL_TRUE_VALUE'] = "woo"
ENV['BOOL_FALSE_VALUE'] = "false"
ENV['SENSIBLE_NAME'] = "cheese"

module TestConfig
  extend Environmentor::Configurable

  environmentor.with_mapper :env do
    attr_config :test_value
    attr_config :default_value, default: "woop"
    attr_config :optional_value, required: false
    attr_config :optional_value_with_default, required: false, default: "badger"
    attr_config :int_value, type: :int
    attr_config :bool_true_value, type: :bool
    attr_config :bool_false_value, type: :bool
    attr_config :weird_name, mappers: {env: {full_name: 'SENSIBLE_NAME'}}
  end
end

module TestRequiredConfig; end

class EnvironmentorTest < Test::Unit::TestCase
  def test_plain_value
    assert_equal "hello", TestConfig.test_value
  end

  def test_required_value
    env_mapper = Environmentor::Mappers::Env.new
    s = Environmentor::Schema.new([env_mapper])

    assert_raise Environmentor::Attribute::RequiredValueNotFound do
      s.attr_config :required_value, required: true
    end
  end

  def test_default_value
    assert_equal "woop", TestConfig.default_value
  end

  def test_optional_value
    assert_nil TestConfig.optional_value
  end

  def test_optional_value_with_default
    assert_equal "badger", TestConfig.optional_value_with_default
  end

  def test_int_value
    assert_equal 42, TestConfig.int_value
  end

  def test_bool_true_value
    assert_equal true, TestConfig.bool_true_value
  end

  def test_bool_false_value
    assert_equal false, TestConfig.bool_false_value
  end

  def test_env_full_name
    assert_equal "cheese", TestConfig.weird_name
  end
end
