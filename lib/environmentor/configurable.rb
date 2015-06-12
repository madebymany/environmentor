require_relative 'config_manager'

module Environmentor
  module Configurable

    def environmentor
      @environmentor_config_manager ||= ConfigManager.new(self)
    end

  end
end
