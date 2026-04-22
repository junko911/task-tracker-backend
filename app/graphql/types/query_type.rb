module Types
  class QueryType < Types::BaseObject
    field :tasks,
      [Types::TaskType],
      null: false,
      description: 'Return all tasks, optionally filtered by status' do
        argument :status, Types::TaskStatusEnum, required: false
      end

    field :task,
      Types::TaskType,
      null: true,
      description: 'Find a task by ID' do
        argument :id, ID, required: true
      end

    def tasks(status: nil)
      if status.present?
        Task.where(status: status).order(created_at: :desc)
      else
        Task.order(created_at: :desc)
      end
    end

    def task(id:)
      Task.find_by(id: id)
    end
  end
end
