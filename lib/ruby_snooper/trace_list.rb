module RubySnooper
  class TraceList
    def initialize(method_name, caller_path)
      @method_name = method_name
      @caller_path = caller_path
      @source_cache = {}
      @lines = []
      @return = nil
    end

    def add(tp)
      return if @method_name != tp.method_id
      return if tp.path != @caller_path

      local_variables = tp.binding.local_variables.map do |name|
        [name, tp.binding.local_variable_get(name).inspect]
      end.to_h

      if @lines.count > 0
        new_variables = local_variables.select { |key,value| !@lines.last.local_variables.has_key?(key) }
        modified_variables = local_variables.select {|key, value| @lines.last.local_variables.has_key?(key) && value != @lines.last.local_variables[key] }
      end

      case tp.event
      when :call, :line
        @lines << Line.new(
          tp.method_id,
          tp.event,
          tp.lineno,
          Time.now,
          code_for(tp.path)[tp.lineno - 1],
          local_variables,
          new_variables,
          modified_variables,
          tp.path,
        )
      when :return
        @return = Return.new(
          tp.method_id,
          tp.event,
          tp.lineno,
          Time.now,
          code_for(tp.path)[tp.lineno - 1],
          tp.return_value,
          tp.path,
        )
      end
    end

    def traces
      @lines + [@return]
    end

    private

    def code_for(filename)
      @source_cache[filename] ||= IO.readlines(filename, chomp: true)
    end

    class Line
      attr_reader :method_id, :event, :number, :time, :code, :local_variables, :new_variables, :modified_variables, :file_path

      def initialize(method_id, event, number, time, code, local_variables, new_variables, modified_variables, file_path)
        @method_id = method_id
        @event = event
        @number = number
        @time = time
        @code = code
        @local_variables = local_variables
        @new_variables = new_variables
        @modified_variables = modified_variables
        @file_path = file_path
      end
    end

    class Return
      attr_reader :method_id, :event, :number, :time, :code, :return_value

      def initialize(method_id, event, number, time, code, return_value, file_path)
        @method_id = method_id
        @event = event
        @number = number
        @time = time
        @code = code
        @return_value = return_value
        @file_path = file_path
      end
    end
  end
end
