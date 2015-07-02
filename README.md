# Environmentor

by Dan Brown <dan@stompydan.net>

Environmentor is a gem to help you provide the correct configuration for your Ruby application from the environment, and/or a configuration store. You define the configuration values you require, with certain types, and Environmentor will abort with a helpful error message if anything required is missing. The current alternatives are less declarative (so more room for error) or leave the discovery of missing configuration until runtime – often too late. Errors are collected and all are shown at once, making it easy to fix all missing or incorrect configuration in one go.

I've designed it for flexibility and transparency. The DSL, such as it is, is only a thin layer around an ordinary Ruby object graph, that is easy to construct yourself if you wish, and therefore also easy to understand and extend. Mappers take values from a given configuration defined by attributes in a schema. They can then map these values onto any ordinary Ruby module.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'environmentor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install environmentor

## Usage

Here's a quick example:

```ruby
module AppConfig
  extend Environmentor::Configurable

  environmentor.with_mapper :env do
    attr_config :welcome_message
  end
end
```

`Environmentor::Configurable` provides the method `environmentor`, which is your entry point to the API here. This is so that the namespace of your module is as unpolluted as possible. `with_mapper` creates a new schema, using mappers that you give. You can pass mappers as their actual `Environmentor::Mapper` instance or by their symbol name. This will create a new mapper with default options.

The schema defines one attribute. The `:env` mapper, using as it does environment variables, will guess that it's looking for a variable called `WELCOME_MESSAGE`. If it's blank, there will be an error.

```ruby
module AppConfig
  extend Environmentor::Configurable

  environmentor.with_mapper :env, prefix: 'MYAPP_' do
    attr_config :welcome_message
    attr_config :aws_access_id, mappers: {env: {full_name: 'AWS_ACCESS_ID'}}
  end
end
```

Here's a slightly more involved example. Here, Environmentor will look for `MYAPP_WELCOME_MESSAGE`, but `AWS_ACCESS_ID`. The prefix is applied by default, but the `:env` mapper's variable name guessing can be overridden. Supplying `name:` instead of `full_name:` would use the prefix.

```ruby
module AppConfig
  extend Environmentor::Configurable

  environmentor.with_mapper :env, prefix: 'MYAPP_' do
    attr_config :num_wibbles, type: :int
    attr_config :ice_cream_flavour, required: false
    attr_config :input_manager, required: false, default: 'auto'
  end
end
```

You can coerce values coming in from the mapper's source. Here, a value will be converted to an integer using `#to_i`. There's also a config attribute `ice_cream_flavour` that isn't required. Environmentor won't raise an error if this isn't present, and the attribute will return `nil`. `input_manager` is also not required, but has a default specified.

```ruby
module AppConfig
  extend Environmentor::Configurable

  environmentor.with_mapper :env, prefix: 'MYAPP_' do
    attr_config :reliable, type: :bool

    namespace :stripe do
      attr_config :api_key
    end
  end
end
```

Last one for now. Here we have `reliable`, which to remind you here will take a value from the environment variable `MYAPP_RELIABLE`, is set as a `:bool`. This will take a boolean-looking value (including understanding `t`, `f`, `yes`, `no`, etc). Also we have a namespace. This is just a nested schema that knows about its parent. So the `api_key` here will be taken from a variable called `MYAPP_STRIPE_API_KEY`.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/environmentor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Please follow style and conventions already in the codebase. Particularly: 80 columns, de-indended `protected`/`private`, whitespace around block brackets, that sort of thing. Thanks!
