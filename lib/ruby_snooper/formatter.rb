require 'coderay'

module RubySnooper
  class Formatter
    def stream(traces, &block)
      traces.each do |trace|
        case trace.event
        when :call
          yield "From #{trace.file_path}"
          yield colorized("Starting var #{variables_str(trace.local_variables)}")
          yield code(trace)
        when :line
          yield colorized("New var      #{variables_str(trace.new_variables)}") if trace.new_variables.count > 0
          yield colorized("Modified var #{variables_str(trace.modified_variables)}") if trace.modified_variables.count > 0
          yield code(trace)
        when :return
          yield code(trace)
          yield colorized("Return value #{trace.return_value}")
        end
      end
    end

    private

    def code(trace)
      "#{trace.time.strftime("%T,%L")} #{trace.event.to_s.ljust(6)} #{trace.number.to_s.rjust(4)} #{code_colorized(trace.code)}"
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
end
