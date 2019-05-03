RSpec.describe RubySnooper do
  it "has a version number" do
    expect(RubySnooper::VERSION).not_to be nil
  end

  describe '.snoop' do
    subject { SampleClass.new.sample_instance_method(1, 2) }

    it do
      expect(STDERR).to receive(:puts).with(/^From.*\/ruby_snooper\/spec\/ruby_snooper_spec.rb$/)
      expect(STDERR).to receive(:puts).with(/^Starting var arg1 = 1, arg2 = 2, arg3 = nil$/)
      expect(STDERR).to receive(:puts).with(/call   57     def sample_instance_*method\(arg1, arg2\)$/)
      expect(STDERR).to receive(:puts).with(/line   58       arg1 \= arg1 \+ 1$/)
      expect(STDERR).to receive(:puts).with(/^Modified var arg1 = 2$/)
      expect(STDERR).to receive(:puts).with(/line   59       arg3 \= arg1 \+ arg2$/)
      expect(STDERR).to receive(:puts).with(/^Modified var arg3 = 4$/)
      expect(STDERR).to receive(:puts).with(/line   60       arg3 \* 2$/)
      expect(STDERR).to receive(:puts).with(/return 61     end$/)
      expect(STDERR).to receive(:puts).with(/Return value 8/)
      subject
    end

    it { is_expected.to eq 8 }
  end

  describe '.snoop_class_methods' do
    subject { SampleClass.sample_class_method(1, 2) }

    it do
      expect(STDERR).to receive(:puts).with(/^From.*\/ruby_snooper\/spec\/ruby_snooper_spec.rb$/)
      expect(STDERR).to receive(:puts).with(/^Starting var arg1 = 1, arg2 = 2, arg3 = nil$/)
      expect(STDERR).to receive(:puts).with(/call   51     def self\.sample_class_method\(arg1, arg2\)$/)
      expect(STDERR).to receive(:puts).with(/line   52       arg1 \= arg1 \+ 1$/)
      expect(STDERR).to receive(:puts).with(/^Modified var arg1 = 2$/)
      expect(STDERR).to receive(:puts).with(/line   53       arg3 \= arg1 \+ arg2$/)
      expect(STDERR).to receive(:puts).with(/^Modified var arg3 = 4$/)
      expect(STDERR).to receive(:puts).with(/line   54       arg3 \* 2$/)
      expect(STDERR).to receive(:puts).with(/return 55     end$/)
      expect(STDERR).to receive(:puts).with(/Return value 8/)
      subject
    end

    it { is_expected.to eq 8 }
  end

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
end
