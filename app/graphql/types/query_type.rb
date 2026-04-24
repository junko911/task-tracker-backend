module Types
  class QueryType < Types::BaseObject
    include GraphqlAuthenticatable

    field :tasks,
      [Types::TaskType],
      null: false,
      description: 'Return all tasks, optionally filtered by status' do
        argument :status, Types::TaskStatusEnum, required: false
      end

    field :me,
      Types::UserType,
      null: false,
      description: 'Return the currently authenticated user'

    field :task,
      Types::TaskType,
      null: true,
      description: 'Find a task by ID' do
        argument :id, ID, required: true
      end

    def me
      require_current_user!
    end

    def tasks(status: nil)
      user = require_current_user!
      scope = user.tasks.order(created_at: :desc)
      if status.present?
        scope.by_status(status)
      else
        scope
      end
    end

    def task(id:)
      user = require_current_user!
      user.tasks.find_by(id: id)
    end
  end
end
