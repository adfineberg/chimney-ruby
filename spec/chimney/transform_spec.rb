require 'spec_helper'
require 'chimney/transform'

RSpec.describe Chimney::Transform do
  it 'transforms one simple struct into another' do
    first_user = FirstUser.new(name: 'john', age: '21')
    second_user = first_user.transform_into(SecondUser)
    expect(first_user).not_to eq second_user
    expect(first_user.name).to eq second_user.name
    expect(first_user.age).to eq second_user.age
  end

  class FirstUser < Dry::Struct
    attribute :name, Types::String.optional
    attribute :age, Types::Coercible::Integer
  end

  class SecondUser < Dry::Struct
    attribute :name, Types::String.optional
    attribute :age, Types::Coercible::Integer
  end

  it 'transforms a nested struct into another' do
    first_user = FirstUser.new(name: 'john', age: '21')
    nesting_first_user = NestingFirstUser.new(user: first_user, users: [first_user])
    nesting_second_user = nesting_first_user.transform_into(NestingSecondUser)
    expect(nesting_first_user).not_to eq nesting_second_user
    expect(nesting_first_user.user).not_to eq nesting_second_user.user
    expect(nesting_first_user.user.name).to eq nesting_second_user.user.name
    expect(nesting_first_user.user.age).to eq nesting_second_user.user.age
    expect(nesting_first_user.users).not_to eq nesting_second_user.users
    expect(nesting_first_user.users.first.name).to eq nesting_second_user.users.first.name
  end

  class NestingFirstUser < Dry::Struct
    attribute :user, FirstUser
    attribute :users, Types::Strict::Array.of(FirstUser)
  end

  class NestingSecondUser < Dry::Struct
    attribute :user, SecondUser
    attribute :users, Types::Strict::Array.of(SecondUser)
  end

  context 'missing values' do
    it 'fails if missing values are not provided' do
      first_user = FirstUser.new(name: 'john', age: '21')
      expect { first_user.transform_into(SecondUserWithGender) }.to raise_exception(Dry::Struct::Error)
    end

    it 'allows providing of missing values' do
      first_user = FirstUser.new(name: 'john', age: '21')
      second_user = first_user.into(SecondUserWithGender).with_field_const(:gender, 'female').transform
      expect(second_user.gender).to eq 'female'
    end

    it 'allows providing missing values dynamically' do
      first_user = FirstUser.new(name: 'john', age: '21')
      dynamic_gender = proc { |user| user.age > 2 ? 'female' : 'male' }
      second_user = first_user.into(SecondUserWithGender).with_field_computed(:gender, dynamic_gender).transform
      expect(second_user.gender).to eq 'female'
    end

    class SecondUserWithGender < Dry::Struct
      attribute :name, Types::String.optional
      attribute :age, Types::Coercible::Integer
      attribute :gender, Types::String
    end

    context 'with defaults' do
      it 'uses the dry struct default value if not provided' do
        first_user = FirstUser.new(name: 'john', age: '21')
        second_user = first_user.transform_into(SecondUserWithDefaultGender)
        expect(second_user.gender).to eq 'female'
      end

      class SecondUserWithDefaultGender < Dry::Struct
        attribute :name, Types::String.optional
        attribute :age, Types::Coercible::Integer
        attribute :gender, Types::String.default('female'.freeze)
      end
    end
  end

  context 'field re-labelling' do
    it 'allows providing of missing values' do
      first_user = FirstUser.new(name: 'john', age: '21')
      renamed_user = first_user.into(FirstUserRenamed)
                      .with_field_renamed(:name, :shem)
                      .with_field_renamed(:age, :gil)
                      .transform
      expect(renamed_user.shem).to eq 'john'
      expect(renamed_user.gil).to eq 21
    end

    class FirstUserRenamed < Dry::Struct
      attribute :shem, Types::String.optional
      attribute :gil, Types::Coercible::Integer
    end

  end
end
