module Mutations
  class CreateTask < BaseMutation
    description 'Create a new task'

    argument :title,       String,                  required: true
    argument :description, String,                  required: false
    argument :status,      Types::TaskStatusEnum,   required: false

    field :task,   Types::TaskType, null: true
    field :errors, [String],        null: false

    def resolve(title:, description: nil, status: nil)
      user = require_current_user!
      task = user.tasks.build(
        title: title,
        description: description,
        status: status || 'pending'
      )

      if task.save
        { task: task, errors: [] }
      else
        { task: nil, errors: task.errors.full_messages }
      end
    end
  end
end
