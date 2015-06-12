module Environmentor
  module TypeCoercer
    class UnknownType < StandardError; end

    extend self

    def coerce_string_to(type, str_val)
      case type
      when :string, :str
        str_val
      when :boolean, :bool
        ![nil, "", "false"].include?(str_val.strip.downcase)
      when :integer, :int
        str_val.to_i
      else
        raise UnknownType, type
      end
    end

    def valid_type?(type)
      %i[ string str boolean bool integer int ].include?(type)
    end
  end
end
