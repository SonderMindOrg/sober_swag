PersonErrorsOutputObject = SoberSwag::OutputObject.define do
  identifier 'PersonErrors'
  field :first_name, primitive(:String).array.optional
  field :last_name, primitive(:String).array.optional
end
