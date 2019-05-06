require "ruby_snooper/version"
require "ruby_snooper/trace_list"
require "ruby_snooper/formatter"

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
    caller_path = caller_locations[1].path
    Module.new do
      method_names.each do |method_name|
        define_method(method_name) do |*args, &block|
          trace_list = RubySnooper::TraceList.new(method_name, caller_path)
          trace_point = TracePoint.new(:call, :line, :return) do |tp|
            trace_list.add(tp)
          end
          trace_point.enable
          super(*args,&block).tap do
            trace_point.disable
            RubySnooper::Formatter.new.stream(trace_list.traces, &(STDERR.method(:puts)))
          end
        end
      end
    end
  end
end
