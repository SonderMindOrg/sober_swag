class PeopleController < ApplicationController

  include SoberSwag::Controller

  before_action :load_person, only: %i[show update]


  PersonBodyParams = SoberSwag.struct do
    sober_name 'PersonBodyParams'

    attribute :first_name, SoberSwag::Types::String
    attribute :last_name, SoberSwag::Types::String
    attribute? :date_of_birth, SoberSwag::Types::Params::DateTime.optional
  end

  PersonParams = SoberSwag.struct do
    sober_name 'PersonParams'
    attribute :person, PersonBodyParams
  end

  PersonSerializer = SoberSwag::Blueprint.define do
    sober_name 'Person'
    field :id, primitive(:Integer)
    field :first_name, primitive(:String)
    field :last_name, primitive(:String)
  end

  define :post, :create, '/people/' do
    request_body(PersonParams)
    response(:ok, 'the person created', PersonSerializer)
  end
  def create
    p = Person.create!(parsed_body.to_h)
    respond!(:ok, p)
  end

  define :patch, :update, '/people/{id}' do
    request_body(PersonParams)
    path_params { attribute :id, Types::Params::Integer }
    response(:ok, 'the person updated', PersonSerializer)
  end
  def update
    if @person.update(parsed_body.to_h)
      respond!(:ok, @person)
    else
      render json: @person.errors, status: :unprocessable_entity
    end
  end

  define :get, :index, '/people/' do
    query_params do
      attribute? :first_name, Types::String
      attribute? :last_name, Types::String
    end
    response(:ok, 'all the people', PersonSerializer.array)
  end

  def index
    @people = Person.all
    @people = @people.where('first_name ILIKE ?', "%#{parsed_query.first_name}%") if parsed_query.first_name
    @people = @people.where('last_name ILIKE ?', "%#{parsed_query.last_name}%") if parsed_query.last_name
    respond!(:ok, @people)
  end

  define :get, :show, '/people/{id}' do
    path_params do
      attribute :id, Types::Params::Integer
    end
    response(:ok, 'the person requested', PersonSerializer)
  end
  def show
    respond!(:ok, @person)
  end

  def load_person
    @person = Person.find(parsed_path.id)
  end
end
