PostBlueprint = SoberSwag::Blueprint.define do
  sober_name 'Post'
  field :id, primitive(:Integer)
  field :title, primitive(:String)
  field :post, primitive(:String)

  view :detail do
    field :person, -> { PersonBlueprint }
  end
end
