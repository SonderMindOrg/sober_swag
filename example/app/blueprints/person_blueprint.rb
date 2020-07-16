PersonBlueprint = SoberSwag::Blueprint.define do
  identifier 'Person'
  field :id, primitive(:Integer).meta(description: 'Unique ID')
  field :first_name, primitive(:String).meta(description: <<~MARKDOWN)
    This is the first name of a person.
    Note that you can't use this as a unique identifier, and you really should understand how names work before using this.
    [Falsehoods programmers believe about names](https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/)
    is a good thing to read!
  MARKDOWN
  field :last_name, primitive(:String)

  view :detail do
    field :posts, -> { PostBlueprint.array }
  end
end
