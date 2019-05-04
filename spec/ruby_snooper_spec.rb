require 'fixtures/sample_class'

RSpec.describe RubySnooper do
  it "has a version number" do
    expect(RubySnooper::VERSION).not_to be nil
  end

  describe '.snoop' do
    subject { SampleClass.new.sample_instance_method(1, 2) }

    it do
      expect(STDERR).to receive(:puts).with(/^From.*\/spec\/fixtures\/sample_class.rb$/)
      expect(STDERR).to receive(:puts).with(/^Starting var arg1 = 1, arg2 = 2, arg3 = nil$/)
      expect(STDERR).to receive(:puts).with(/call   12   .*def.* .*sample_instance_method.*\(arg1, arg2\)$/)
      expect(STDERR).to receive(:puts).with(/line   13     arg1 \= arg1 \+ .*1/)
      expect(STDERR).to receive(:puts).with(/^Modified var arg1 = 2$/)
      expect(STDERR).to receive(:puts).with(/line   14     arg3 \= arg1 \+ arg2$/)
      expect(STDERR).to receive(:puts).with(/^Modified var arg3 = 4$/)
      expect(STDERR).to receive(:puts).with(/line   15     arg3 \* .*2/)
      expect(STDERR).to receive(:puts).with(/return 16   .*end/)
      expect(STDERR).to receive(:puts).with(/Return value 8/)
      subject
    end

    it { is_expected.to eq 8 }
  end

  describe '.snoop_class_methods' do
    subject { SampleClass.sample_class_method(1, 2) }

    it do
      expect(STDERR).to receive(:puts).with(/^From.*\/spec\/fixtures\/sample_class.rb$/)
      expect(STDERR).to receive(:puts).with(/^Starting var arg1 = 1, arg2 = 2, arg3 = nil$/)
      expect(STDERR).to receive(:puts).with(/call   6   .*def.* .*self.*\..*sample_class_method.*\(arg1, arg2\)$/)
      expect(STDERR).to receive(:puts).with(/line   7     arg1 \= arg1 \+ .*1/)
      expect(STDERR).to receive(:puts).with(/^Modified var arg1 = 2$/)
      expect(STDERR).to receive(:puts).with(/line   8     arg3 \= arg1 \+ arg2$/)
      expect(STDERR).to receive(:puts).with(/^Modified var arg3 = 4$/)
      expect(STDERR).to receive(:puts).with(/line   9     arg3 \* .*2/)
      expect(STDERR).to receive(:puts).with(/return 10   .*end/)
      expect(STDERR).to receive(:puts).with(/Return value 8/)
      subject
    end

    it { is_expected.to eq 8 }
  end
end
