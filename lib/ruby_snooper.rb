require "ruby_snooper/version"
require "ruby_snooper/trace_writer"

module RubySnooper
  class Error < StandardError; end

  def snoop(*method_names)
    to_prepend = Module.new do
      method_names.each do |method_name|
        define_method(method_name) do |*args, &block|
          trace_writer = TraceWriter.new(
            method_names,
            caller_locations.first.path,
          )
          trace_writer.trace_point.enable
          super(*args,&block).tap do
            trace_writer.trace_point.disable
            trace_writer.print
          end
        end
      end
    end
    prepend to_prepend
  end
end
