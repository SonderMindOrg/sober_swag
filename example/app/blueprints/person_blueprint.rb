PersonBlueprint = SoberSwag::Blueprint.define do
  sober_name 'Person'
  field :id, primitive(:Integer)
  field :first_name, primitive(:String)
  field :last_name, primitive(:String)

  view :detail do
    field :posts, -> { PostBlueprint.array }
  end
end
