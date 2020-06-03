PostBlueprint = SoberSwag::Blueprint.define do
  sober_name 'Post'
  field :id, primitive(:Integer)
  field :title, primitive(:String)
  field :body, primitive(:String)

  view :detail do
    field :person, -> { PersonBlueprint.view(:base) }
  end
end
