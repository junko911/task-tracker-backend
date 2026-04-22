module Types
  class TaskType < Types::BaseObject
    field :id,          ID,             null: false
    field :title,       String,         null: false
    field :description, String,         null: true
    field :status,      TaskStatusEnum, null: false
    field :created_at,  String,         null: false
    field :updated_at,  String,         null: false

    def created_at
      object.created_at.iso8601
    end

    def updated_at
      object.updated_at.iso8601
    end
  end
end
