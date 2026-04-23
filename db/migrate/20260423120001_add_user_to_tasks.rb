class AddUserToTasks < ActiveRecord::Migration[7.1]
  def up
    add_reference :tasks, :user, foreign_key: true

    say_with_time 'Assigning existing tasks to migration user' do
      user = User.find_or_initialize_by(email: 'migration@tasktracker.local')
      if user.new_record?
        pw = SecureRandom.hex(32)
        user.password = pw
        user.password_confirmation = pw
        user.save!
      end
      Task.where(user_id: nil).update_all(user_id: user.id)
    end

    change_column_null :tasks, :user_id, false
  end

  def down
    remove_reference :tasks, :user, foreign_key: true
  end
end
