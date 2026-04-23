module Mutations
  class SignIn < BaseMutation
    description 'Sign in with email and password (returns API token)'

    argument :email,    String, required: true
    argument :password, String, required: true

    field :user,      Types::UserType, null: true
    field :api_token, String,          null: true
    field :errors,    [String],       null: false

    def resolve(email:, password:)
      user = User.find_by(email: email.to_s.downcase.strip)
      unless user&.authenticate(password)
        return { user: nil, api_token: nil, errors: ['Invalid email or password'] }
      end

      { user: user, api_token: user.api_token, errors: [] }
    end
  end
end
