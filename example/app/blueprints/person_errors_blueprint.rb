PersonErrorsBlueprint = SoberSwag::Blueprint.define do
  sober_name 'PersonErrors'
  field :first_name, primitive(:String).array.optional
  field :last_name, primitive(:String).array.optional
end
