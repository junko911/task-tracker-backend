module Mutations
  class UpdateTask < BaseMutation
    description 'Update an existing task'

    argument :id,          ID,                      required: true
    argument :title,       String,                  required: false
    argument :description, String,                  required: false
    argument :status,      Types::TaskStatusEnum,   required: false

    field :task,   Types::TaskType, null: true
    field :errors, [String],        null: false

    def resolve(id:, title: nil, description: nil, status: nil)
      user = require_current_user!
      task = user.tasks.find_by(id: id)

      return { task: nil, errors: ['Task not found'] } unless task

      attrs = {}
      attrs[:title]       = title            unless title.nil?
      attrs[:description] = description.presence unless description.nil?
      attrs[:status]      = status           unless status.nil?

      if task.update(attrs)
        { task: task, errors: [] }
      else
        { task: nil, errors: task.errors.full_messages }
      end
    end
  end
end
