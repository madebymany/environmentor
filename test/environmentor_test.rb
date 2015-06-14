require 'test_helper'

ENV['TEST_VALUE'] = "hello"
ENV['INT_VALUE'] = "42"
ENV['BOOL_TRUE_VALUE'] = "woo"
ENV['BOOL_FALSE_VALUE'] = "false"
ENV['SENSIBLE_NAME'] = "cheese"

ENV['GOOD_SERVICE_TOKEN'] = "xxyyzz"
ENV['GOOD_SERVICE_ENABLED'] = "1"
ENV['GOOD_SERVICE_THINGS_STUFF'] = "klaxon"

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

    namespace :good_service do
      attr_config :token
      attr_config :enabled, type: :bool, default: true

      namespace :things do
        attr_config :stuff
      end
    end
  end
end

module TestRequiredConfig; end

class TestClass
  extend Environmentor::Configurable

  environmentor.with_mapper :env do
    attr_config :test_value
  end
end

class DelegateConfigClass
  extend Environmentor::Configurable

  environmentor.delegate_to TestConfig
end

class EnvironmentorTest < Minitest::Test
  def test_plain_value
    assert_equal "hello", TestConfig.test_value
  end

  def test_required_value
    env_mapper = Environmentor::Mappers::Env.new
    s = Environmentor::Schema.new([env_mapper])
    s.attr_config :required_value, required: true
    errors = s.validate!

    assert !errors.success?, "errors expected"
    assert_equal 1, errors.size
    assert_equal Environmentor::Attribute::ValidationError::Missing, errors.first.class
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

  def test_basic_namespace
    assert_equal "xxyyzz", TestConfig.good_service.token
    assert_equal true, TestConfig.good_service.enabled
  end

  def test_nested_namespace
    assert_equal "klaxon", TestConfig.good_service.things.stuff
  end

  def test_values_in_class
    assert_equal "hello", TestClass.test_value
    assert_equal "hello", TestClass.new.test_value
  end

  def test_delegated
    assert_equal "hello", DelegateConfigClass.test_value
    assert_equal "hello", DelegateConfigClass.new.test_value
  end
end
