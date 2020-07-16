class PeopleController < ApplicationController

  include SoberSwag::Controller

  before_action :load_person, only: %i[show update]


  PersonBodyParams = SoberSwag.struct do
    identifier 'PersonBodyParams'

    attribute :first_name, SoberSwag::Types::String
    attribute :last_name, SoberSwag::Types::String
    attribute? :date_of_birth, SoberSwag::Types::Params::DateTime.optional
  end

  PersonBodyPatchParams = SoberSwag.struct(PersonBodyParams) do
    identifier 'PersonBodyPatchParams'

    attribute? :first_name, SoberSwag::Types::String
    attribute? :last_name, SoberSwag::Types::String
    attribute? :date_of_birth, SoberSwag::Types::Params::DateTime.optional
  end

  PersonParams = SoberSwag.struct do
    identifier 'PersonParams'
    attribute :person, PersonBodyParams
  end

  PersonPatchParams = SoberSwag.struct do
    identifier 'PersonPatchParams'
    attribute :person, PersonBodyPatchParams
  end

  define :post, :create, '/people/' do
    request_body(PersonParams)
    response(:ok, 'the person created', PersonBlueprint)
    response(:unprocessable_entity, 'the validation errors', PersonErrorsBlueprint)
  end
  def create
    p = Person.new(parsed_body.person.to_h)
    if p.save
      respond!(:ok, p)
    else
      respond!(:unprocessable_entity, p.errors)
    end
  end

  define :patch, :update, '/people/{id}' do
    request_body(PersonPatchParams)
    path_params { attribute :id, Types::Params::Integer }
    response(:ok, 'the person updated', PersonBlueprint)
    response(:unprocessable_entity, 'the validation errors', PersonErrorsBlueprint)
  end
  def update
    if @person.update(parsed_body.person.to_h)
      respond!(:ok, @person)
    else
      respond!(:unprocessable_entity, @person.errors)
    end
  end

  define :get, :index, '/people/' do
    query_params do
      attribute? :first_name, Types::String
      attribute? :last_name, Types::String
      attribute? :view, Types::String.enum('base', 'detail')
    end
    response(:ok, 'all the people', PersonBlueprint.array)
  end
  def index
    @people = Person.all
    @people = @people.where('first_name ILIKE ?', "%#{parsed_query.first_name}%") if parsed_query.first_name
    @people = @people.where('last_name ILIKE ?', "%#{parsed_query.last_name}%") if parsed_query.last_name
    respond!(:ok, @people.includes(:posts), serializer_opts: { view: parsed_query.view })
  end

  define :get, :show, '/people/{id}' do
    path_params do
      attribute :id, Types::Params::Integer
    end
    response(:ok, 'the person requested', PersonBlueprint)
  end
  def show
    respond!(:ok, @person)
  end

  def load_person
    @person = Person.find(parsed_path.id)
  end
end
