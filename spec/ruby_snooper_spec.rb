RSpec.describe RubySnooper do
  it "has a version number" do
    expect(RubySnooper::VERSION).not_to be nil
  end

  describe '#snoop' do
    subject { SampleClass.new.sample_method(1, 2) }

    it do
      expect(STDOUT).to receive(:puts).with(/^From.*\/ruby_snooper\/spec\/ruby_snooper_spec.rb$/)
      expect(STDOUT).to receive(:puts).with(/^Starting var arg1 = 1, arg2 = 2, arg3 = nil$/)
      expect(STDOUT).to receive(:puts).with(/call   30     def sample_method\(arg1, arg2\)$/)
      expect(STDOUT).to receive(:puts).with(/line   31       arg1 \= arg1 \+ 1$/)
      expect(STDOUT).to receive(:puts).with(/^Modified var arg1 = 2$/)
      expect(STDOUT).to receive(:puts).with(/line   32       arg3 \= arg1 \+ arg2$/)
      expect(STDOUT).to receive(:puts).with(/^Modified var arg3 = 4$/)
      expect(STDOUT).to receive(:puts).with(/line   33       arg3 \* 2$/)
      expect(STDOUT).to receive(:puts).with(/return 34     end$/)
      expect(STDOUT).to receive(:puts).with(/Return value 8/)
      subject
    end

    it { is_expected.to eq 8 }
  end

  class SampleClass
    extend RubySnooper
    snoop :sample_method

    def sample_method(arg1, arg2)
      arg1 = arg1 + 1
      arg3 = arg1 + arg2
      arg3 * 2
    end
  end
end
