PostBlueprint = SoberSwag::Blueprint.define do
  identifier 'Post'
  field :id, primitive(:Integer)
  field :title, primitive(:String)
  field :body, primitive(:String)

  view :detail do
    field :person, -> { PersonBlueprint.view(:base) }
  end
end
