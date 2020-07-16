class PeopleController < ApplicationController

  include SoberSwag::Controller

  before_action :load_person, only: %i[show update]


  PersonBodyParams = SoberSwag.input_object do
    identifier 'PersonBodyParams'

    attribute :first_name, SoberSwag::Types::String
    attribute :last_name, SoberSwag::Types::String
    attribute? :date_of_birth, SoberSwag::Types::Params::DateTime.optional
  end

  PersonBodyPatchParams = SoberSwag.input_object(PersonBodyParams) do
    identifier 'PersonBodyPatchParams'

    attribute? :first_name, SoberSwag::Types::String
    attribute? :last_name, SoberSwag::Types::String
    attribute? :date_of_birth, SoberSwag::Types::Params::DateTime.optional
  end

  PersonParams = SoberSwag.input_object do
    identifier 'PersonParams'
    attribute :person, PersonBodyParams
  end

  PersonPatchParams = SoberSwag.input_object do
    identifier 'PersonPatchParams'
    attribute :person, PersonBodyPatchParams
  end

  define :post, :create, '/people/' do
    request_body(PersonParams)
    response(:ok, 'the person created', PersonOutputObject)
    response(:unprocessable_entity, 'the validation errors', PersonErrorsOutputObject)
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
    response(:ok, 'the person updated', PersonOutputObject)
    response(:unprocessable_entity, 'the validation errors', PersonErrorsOutputObject)
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
    response(:ok, 'all the people', PersonOutputObject.array)
  end
  def index
    @people = Person.all
    @people = @people.where('UPPER(first_name) LIKE UPPER(?)', "%#{parsed_query.first_name}%") if parsed_query.first_name
    @people = @people.where('UPPER(last_name) LIKE UPPER(?)', "%#{parsed_query.last_name}%") if parsed_query.last_name
    respond!(:ok, @people.includes(:posts), serializer_opts: { view: parsed_query.view })
  end

  define :get, :show, '/people/{id}' do
    path_params do
      attribute :id, Types::Params::Integer
    end
    response(:ok, 'the person requested', PersonOutputObject)
  end
  def show
    respond!(:ok, @person)
  end

  def load_person
    @person = Person.find(parsed_path.id)
  end
end
