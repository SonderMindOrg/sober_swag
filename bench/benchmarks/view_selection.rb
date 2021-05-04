##
# Benchmark for speed of selecting what view to use.
class ViewSelection
  Accomplishment = Struct.new(:name, :description)
  Person = Struct.new(:first_name, :last_name, :accomplishments)

  MyPerson = Person.new(
    'Joeseph',
    'Biden',
    [
      Accomplishment.new('Became President', 'Won a Presidential Election'),
      Accomplishment.new('Oldest President', 'Oldest man to be elected president at time of election'),
      Accomplishment.new('Became Senator', 'Got Elected to the Senate'),
      Accomplishment.new('Youngest Senator', 'Youngest person elected Senator at time of election')
    ]
  )

  AccomplishmentSerializer = SoberSwag::OutputObject.define do
    field :name, primitive(:String)

    view :detail do
      field :description, primitive(:String)
    end
  end

  PersonSerializer = SoberSwag::OutputObject.define do
    field :first_name, primitive(:String)
    field :last_name, primitive(:String)

    # make a bunch of dummy views
    1.upto(10).each { |n| view(:"view_#{n}") {} }

    view :detail do
      field :accomplishments, AccomplishmentSerializer.view(:detail)
    end

    1.upto(10).each { |n| view(:"view_after_#{n}") {} }
  end

  Bench.report 'View Selection' do |bm|
    bm.report('With no view') { PersonSerializer.serialize(MyPerson) }

    bm.report('With a view') { PersonSerializer.serialize(MyPerson, { view: :detail }) }

    bm.compare!
  end
end
