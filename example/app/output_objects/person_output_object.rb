##
# Output object that serializes a person.
class PersonOutputObject < IdentifiedOutput
  identifier 'PersonOutput'

  description <<~MARKDOWN
    Basic as hell serializer for a person.
  MARKDOWN

  field :id, SoberSwag::Reporting::Output::Text.new.via_map(&:to_s)
  field(
    :first_name,
    SoberSwag::Reporting::Output::Text.new,
    description: <<~MARKDOWN
      This is the first name of a person.
      Note that you can't use this as a unique identifier, and you really should understand how names work before using this.
      [Falsehoods programmers believe about names](https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/)
      is a good thing to read!
    MARKDOWN
  )
  field(
    :last_name, SoberSwag::Reporting::Output::Text.new
  )

  define_view :detail do
    field(
      :initials,
      SoberSwag::Reporting::Output::Text.new
    ) do |person|
      [person.first_name[0..0], person.last_name[0..0]].compact.map { |x| "#{x}." }.join(' ')
    end

    field(
      :posts,
      SoberSwag::Reporting::Output::Defer.defer do
        ReportingPostOutput.view(:base).array
      end,
      description: 'all posts this user has made'
    )
  end
end
