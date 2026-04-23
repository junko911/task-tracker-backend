module Mutations
  class SignUp < BaseMutation
    description 'Register a new user (returns API token for Authorization header)'

    argument :email,    String, required: true
    argument :password, String, required: true

    field :user,      Types::UserType, null: true
    field :api_token, String,          null: true
    field :errors,    [String],       null: false

    def resolve(email:, password:)
      user = User.new(
        email: email,
        password: password,
        password_confirmation: password
      )

      if user.save
        { user: user, api_token: user.api_token, errors: [] }
      else
        { user: nil, api_token: nil, errors: user.errors.full_messages }
      end
    end
  end
end
