module Types
  class TaskStatusEnum < GraphQL::Schema::Enum
    value 'pending',     'Task has not been started'
    value 'in_progress', 'Task is currently being worked on'
    value 'completed',   'Task has been finished'
  end
end
