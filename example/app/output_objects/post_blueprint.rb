PostOutputObject = SoberSwag::OutputObject.define do
  identifier 'Post'
  field :id, primitive(:Integer)
  field :title, primitive(:String)
  field :body, primitive(:String)

  view :detail do
    field :person, -> { PersonOutputObject.view(:base) }
  end
end
