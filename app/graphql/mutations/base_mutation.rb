module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    include GraphqlAuthenticatable

    argument_class Types::BaseArgument
    field_class Types::BaseField
    object_class Types::BaseObject
  end
end
