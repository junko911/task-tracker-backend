require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: 'taskowner@example.com',
      password: 'password12',
      password_confirmation: 'password12'
    )
  end

  test 'requires title' do
    task = @user.tasks.build(title: '', status: 'pending')
    assert_not task.valid?
  end

  test 'requires user' do
    task = Task.new(title: 'x', status: 'pending')
    assert_not task.valid?
  end
end
