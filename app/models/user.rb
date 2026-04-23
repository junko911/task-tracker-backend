class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_token

  has_many :tasks, dependent: :destroy

  before_validation :normalize_email

  validates :email, presence: true,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, allow_nil: true

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end
end
