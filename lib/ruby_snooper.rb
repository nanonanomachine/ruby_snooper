require "ruby_snooper/version"
require "ruby_snooper/trace_writer"

module RubySnooper
  class Error < StandardError; end

  CLASS_NAME_PATTERN = /\<class\:(\w+)\>/.freeze

  def snoop(*method_names)
    prepend to_prepend(method_names)
  end

  def snoop_class_methods(*method_names)
    Kernel.const_get(caller_locations.first.label.match(CLASS_NAME_PATTERN)[1])
          .singleton_class
          .prepend(to_prepend(method_names))
  end

  private

  def to_prepend(method_names)
    Module.new do
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
  end
end
