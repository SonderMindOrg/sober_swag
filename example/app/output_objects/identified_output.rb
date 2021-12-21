##
# Base serializer for objects with a global id of some variety.
class IdentifiedOutput < SoberSwag::Reporting::Output::Struct
  field :global_id, SoberSwag::Reporting::Output.text.nilable do
    object_to_serialize.try(:to_global_id).try(:to_s)
  end
end
