# chimney-ruby
This gem allows easy transformation between two dry-struct classes.
A port of the Scala chimney library (https://scalalandio.github.io/chimney) 
idea to allow usage over dry-structs in Ruby (https://dry-rb.org/gems/dry-struct/1.0/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chimney-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chimney-ruby

## Usage

This gem allows easy transformation between two dry-struct classes.
Given two classes as such:
```ruby
class FirstUser < Dry::Struct
  attribute :name, Types::String.optional
  attribute :age, Types::Coercible::Integer
end

class SecondUser < Dry::Struct
  attribute :name, Types::String.optional
  attribute :age, Types::Coercible::Integer
end  
````
You can create an immutable instance of the first class using `transform_into`:
```ruby
first_user = FirstUser.new(name: 'john', age: '21')
second_user = first_user.transform_into(SecondUser)
```

For more advanced usages use `into` with `transform`, currently supported are:
### Add missing values
Either statically:
```ruby
class SecondUserWithFeeling < Dry::Struct
  attribute :name, Types::String.optional
  attribute :age, Types::Coercible::Integer
  attribute :feeling, Types::String
end

first_user = FirstUser.new(name: 'john', age: '21')
second_user = first_user.into(SecondUserWithFeeling)
                .with_field_const(:feeling, 'happy')
                .transform
```
Or dynamically using a proc:
```ruby
dynamic_feeling = proc { |user| user.age > 2 ? 'sad' : 'happy' }
second_user = first_user.into(SecondUserWithFeeling)
                .with_field_computed(:feeling, dynamic_feeling)
                .transform
```
### Provide default values
```ruby
class SecondUserWithDefaultFeeling < Dry::Struct
  attribute :name, Types::String.optional
  attribute :age, Types::Coercible::Integer
  attribute :feeling, Types::String.default('happy'.freeze)
end

first_user = FirstUser.new(name: 'john', age: '21')
second_user = first_user.transform_into(SecondUserWithDefaultFeeling)
```
### Re-labelling fields
```ruby
class FirstUserRenamed < Dry::Struct
  attribute :shem, Types::String.optional
  attribute :gil, Types::Coercible::Integer
end

first_user = FirstUser.new(name: 'john', age: '21')
renamed_user = first_user.into(FirstUserRenamed)
                  .with_field_renamed(:name, :shem)
                  .with_field_renamed(:age, :gil)
                  .transform
```
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adfineberg/chimney-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Chimney::Ruby project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/adfineberg/chimney-ruby/blob/master/CODE_OF_CONDUCT.md).
