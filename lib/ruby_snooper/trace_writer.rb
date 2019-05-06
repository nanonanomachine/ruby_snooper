require 'coderay'

module RubySnooper
  class TraceWriter
    def initialize(method_name, caller_path)
      @method_name = method_name
      @caller_path = caller_path
      @source_cache = {}
      @lines = []
      @return = nil
    end

    def code_for(filename)
      @source_cache[filename] ||= IO.readlines(filename, chomp: true)
    end

    def print
      @lines.each(&:print)
      @return.print
    end

    def traces
      @lines + [@return]
    end

    def trace_point
      @trace_point ||= TracePoint.new(:call, :line, :return) do |tp|
        next if @method_name != tp.method_id
        next if tp.path != @caller_path

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

      def print
        STDERR.puts "From #{@file_path}" if @event == :call
        print_variables
        STDERR.puts "#{Time.now.strftime("%T,%L")} #{@event}   #{number.to_s.rjust(4)} #{code_colorized(code)}"
      end

      private

      def print_variables
        case @event
        when :call
          STDERR.puts colorized("Starting var #{variables_str(@local_variables)}")
        when :line
          STDERR.puts colorized("New var      #{variables_str(@new_variables)}") if @new_variables.count > 0
          STDERR.puts colorized("Modified var #{variables_str(@modified_variables)}") if @modified_variables.count > 0
        end
      end

      def variables_str(variables)
        variables.map do |key, value|
          "#{key} = #{value}"
        end.join(', ')
      end

      def code_colorized(str)
        ::CodeRay.scan(str, :ruby).term
      end

      def colorized(str)
        "\e[0;31m#{str}\e[0m"
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

      def print
        STDERR.puts "#{Time.now.strftime("%T,%L")} #{@event} #{@number.to_s.rjust(4)} #{code_colorized(@code)}"
        STDERR.puts colorized("Return value #{@return_value}")
      end

      def code_colorized(str)
        ::CodeRay.scan(str, :ruby).term
      end

      def colorized(str)
        "\e[0;31m#{str}\e[0m"
      end
    end
  end
end
