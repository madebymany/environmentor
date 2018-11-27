module Environmentor
  module TypeCoercer
    class UnknownType < StandardError; end

    extend self

    def coerce_to(type, val)
      coercer = type_coercers[type] or
        raise UnknownType, type
      coercer.call val
    end

    def valid_type?(type)
      type_coercers.keys.include? type
    end

    def register_type(*type_names, &block)
      raise ArgumentError, "No type names given" if type_names.empty?
      raise ArgumentError, "No block given" unless block_given?
      raise ArgumentError, "Block should have arity of 1, taking value to coerce" unless block.arity == 1

      type_names.each do |tn|
        type_coercers[tn] = block
      end
      nil
    end

  private

    def type_coercers
      @type_coercers ||= {}
    end

    register_type :string, :str do |val|
      val.to_s
    end

    register_type :integer, :int do |val|
      val.to_i
    end

    register_type :array, :array do |val|
      val.split(',').map(&:strip)
    end

    register_type :boolean, :bool do |val|
      case val
      when true, false
        val
      when nil, "false", 0, "0", "no", "f"
        false
      else
        val.respond_to?(:empty?) ? !val.empty? : true
      end
    end

    register_type :file_contents do |val|
      case val
      when Pathname
        val.read
      when String
        if val.size == 0
          raise ValueError.new("cannot get file contents when name is empty")
        else
          File.read val
        end
      else
        raise ValueError.new("invalid path name")
      end
    end

  end
end
