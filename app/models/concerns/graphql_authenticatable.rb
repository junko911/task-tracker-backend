module GraphqlAuthenticatable
  extend ActiveSupport::Concern

  private

  def current_user
    context[:current_user]
  end

  def require_current_user!
    raise GraphQL::ExecutionError, 'Authentication required' if current_user.blank?

    current_user
  end
end
