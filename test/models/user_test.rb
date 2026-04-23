require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'creates user with api_token' do
    user = User.create!(
      email: 'one@example.com',
      password: 'password12',
      password_confirmation: 'password12'
    )
    assert user.api_token.present?
  end

  test 'rejects short password' do
    user = User.new(
      email: 'two@example.com',
      password: 'short',
      password_confirmation: 'short'
    )
    assert_not user.valid?
  end

  test 'normalizes email uniqueness case-insensitive' do
    User.create!(
      email: 'Mix@Example.com',
      password: 'password12',
      password_confirmation: 'password12'
    )
    dup = User.new(
      email: 'mix@example.com',
      password: 'password12',
      password_confirmation: 'password12'
    )
    assert_not dup.valid?
  end
end
