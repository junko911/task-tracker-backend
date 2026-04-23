class Task < ApplicationRecord
  belongs_to :user

  enum :status, {
    pending: 'pending',
    in_progress: 'in_progress',
    completed: 'completed'
  }

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :status, presence: true

  scope :by_status, ->(status) { where(status: status) if status.present? }

  before_validation :set_default_status, on: :create

  private

  def set_default_status
    self.status ||= 'pending'
  end
end
