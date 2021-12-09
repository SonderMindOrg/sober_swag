##
# A reporting output object for a post.
class ReportingPostOutput < SoberSwag::Reporting::Output::Struct
  identifier 'ReportingPostOutput'

  field :id, SoberSwag::Reporting::Output::Text.new.via_map(&:to_s)
  field :title, SoberSwag::Reporting::Output::Text.new
  field :body, SoberSwag::Reporting::Output::Text.new

  define_view :detail do
    field(
      :person,
      SoberSwag::Reporting::Output::Defer.defer do
        PersonOutputObject.view(:base)
      end
    )
  end
end
