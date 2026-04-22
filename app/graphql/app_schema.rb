class AppSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Dataloader

  def self.resolve_type(_abstract_type, _obj, _ctx)
    raise(GraphQL::RequiredImplementationMissingError)
  end

  def self.object_from_id(id, _query_ctx)
    # Global ID resolution - not required for this app
    nil
  end

  def self.id_from_object(object, _type_definition, _query_ctx)
    object.id.to_s
  end
end
