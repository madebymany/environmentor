Environmentor.register_mapper :env, :my_app_env, prefix: 'MYAPP_'
Environmentor.register_mapper :etcd, :my_app_etcd, host: 'localhost'

# or

Environmentor.configure_mapper :env, prefix: 'MYAPP_'
# and use mapper `:env` below if you don't care about registering mappers
# and just want to change the global defaults

# or make a mapper yourself and pass it in as a plain object
my_app_env_mapper = Environmentor::Mappers::Env.new(prefix: 'MYAPP_')
# or maybe
my_app_env_mapper = Environmentor.new_mapper(:env, prefix: 'MYAPP_')


# *escapable* magic!

module AppConfig
  extend Environmentor::Configurable

  dev_defaults = Rails.env.development? &&
    Environmentor.new_mapper(
      :yaml, file_name: Rails.root.join("config/defaults.yml"))

  environmentor mapper: dev_defaults || [:my_app_env] do
    attr_config :stripe_key, description: 'Private Stripe API key'
    attr_config :blah, required: false # defaults to true

    namespace :aws do # defaults to prefixing 'AWS_' to env var
      attr_config :region
    end
  end

  # Note one mapper can override another.
  environmentor mapper: dev_defaults || [:my_app_env, :my_app_etcd] do
    attr_config :read_only_mode, type: :boolean, default: false,
      description: 'Runs the app in read-only mode'
    attr_config :some_date, type: :datetime, default: -> { DateTime.now }

    namespace :honeybadger do
      attr_config :token
      attr_config :enabled, type: :boolean, default: true,
        mappers: {env: {full_name: 'HB_ON'}}
    end
  end

end


# Elsewhere..

puts AppConfig.stripe_key
p AppConfig.honeybadger.enabled

# or inject into classes:

class SomeController
  extend Environmentor::Configurable

  environmentor delegate_to: AppConfig do
    attr_config :stripe_key, on_change: :reset_stripe_client
    attr_config :some_date
  end

  def a_method
    Stripe.call(stripe_key)
  end

  def self.reset_stripe_client
    # things
    something_with(stripe_key)
  end
end
