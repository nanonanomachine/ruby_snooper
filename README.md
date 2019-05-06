# RubySnooper

RubySnooper is Poor man's debugger heavily inspired by [PySnooper](https://github.com/cool-RR/PySnooper)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_snooper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_snooper

## Usage

```ruby
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

SampleClass.new.sample_instance_method(1, 2)
SampleClass.sample_class_method(1, 2)
```

The output to stderr is:

```
From /some/file/path.rb
Starting var arg1 = 1, arg2 = 2, arg3 = nil
02:06:31,239 call   59     def sample_instance_method(arg1, arg2)
02:06:31,239 line   60       arg1 = arg1 + 1
Modified var arg1 = 2
02:06:31,239 line   61       arg3 = arg1 + arg2
Modified var arg3 = 4
02:06:31,239 line   62       arg3 * 2
02:06:31,239 return 63     end
Return value 8
From /some/file/path.rb
Starting var arg1 = 1, arg2 = 2, arg3 = nil
02:06:31,240 call   53     def self.sample_class_method(arg1, arg2)
02:06:31,240 line   54       arg1 = arg1 + 1
Modified var arg1 = 2
02:06:31,240 line   55       arg3 = arg1 + arg2
Modified var arg3 = 4
02:06:31,241 line   56       arg3 * 2
02:06:31,241 return 57     end
Return value 8
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nanonanomachine/ruby_snooper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RubySnooper project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nanonanomachine/ruby_snooper/blob/master/CODE_OF_CONDUCT.md).
