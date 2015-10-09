require 'test_helper'

class SchemaTest < Minitest::Test

  def setup
    @env_mapper = Environmentor.new_mapper(:env)
    @mappers = [@env_mapper]
    @cls = Environmentor::Schema
  end

  def create(mappers = @mappers, *args, **opts, &block)
    @cls.new(mappers, *args, **opts, &block)
  end

  def test_defined_at
    defined_at = create.defined_at
    assert { String === defined_at }
    assert { defined_at.size > 0 }
  end

  def test_parent
    parent_schema = create
    schema = create(@mappers, parent_schema, :test)
    assert { schema.parent.equal? parent_schema }
  end

  def test_parent_needs_name
    parent_schema = create

    assert_raises ArgumentError do
      create(@mappers, parent_schema)
    end

    schema = create(@mappers, parent_schema, :test)
    assert { @cls === schema } 
    assert { schema.name == :test }
  end

  def test_attr_config
    schema = create
    assert { schema.attrs.empty? }
    schema.attr_config :test_attr
    assert { schema.attrs.size == 1 }
  end

  def test_namespace
    schema = create
    assert { schema.children.size == 0 }
    schema.namespace(:test) { }
    assert { schema.children.size == 1 }
    assert { schema.children.first.name == :test }
  end

  def test_namespace_without_name
    schema = create
    assert_raises(ArgumentError) do
      schema.namespace(nil) { }
    end
  end

  def test_validate_success
    schema = create {
      attr_config :test_value
    }
    assert { schema.validate.success? }
    assert { schema.validate!.success? }
  end

  def test_validate_failure
    schema = create {
      attr_config :missing_test_value
    }
    errs = schema.validate
    deny { errs.success? }
    assert { errs.size == 1 }
    deny { schema.validate!.success? }

    attr = errs.first.attr
    assert { schema.attrs.has_key? attr.name }
    assert { schema.attrs[attr.name] == attr }
    assert { errs.first.message.size > 0 }
  end

  def test_map_to
    schema = create {
      attr_config :test_value
      namespace :good_service do
        attr_config :token
      end
    }
    mod = Module.new
    schema.map_to mod

    assert { mod.test_value == "hello" }
    assert { mod.good_service.token == "xxyyzz" }
  end

  def test_get_attr
    schema = create {
      attr_config :test_value
    }

    attr = schema.attrs.values.first
    assert { schema.get_attr(attr) == "hello" }
  end

  def test_file_contents_type_errors
    schema = create {
      attr_config :missing_file, type: :file_contents
    }

    errs = schema.validate
    assert { errs.size == 1 }
  end

  def test_file_content_type
    schema = create {
      attr_config :present_file, type: :file_contents
    }

    errs = schema.validate
    assert { errs.size == 0 }

    mod = Module.new
    schema.map_to mod

    assert { mod.present_file.size > 0 }
    assert { mod.present_file.include?("ENV") }
  end

end
