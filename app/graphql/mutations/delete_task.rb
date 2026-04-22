module Mutations
  class DeleteTask < BaseMutation
    description 'Delete a task'

    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors,  [String], null: false

    def resolve(id:)
      task = Task.find_by(id: id)

      return { success: false, errors: ['Task not found'] } unless task

      task.destroy
      { success: true, errors: [] }
    end
  end
end
