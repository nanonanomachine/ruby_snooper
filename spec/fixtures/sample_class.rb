class SampleClass
  extend RubySnooper
  snoop :sample_instance_method
  snoop_class_methods :sample_class_method

  def self.sample_class_method(arg1, arg2)
    arg1 = arg1 + 1
    arg3 = arg1 + arg2
    arg3 * 2
  end

  def sample_instance_method(arg1, arg2)
    arg1 = arg1 + 1
    arg3 = arg1 + arg2
    arg3 * 2
  end
end
