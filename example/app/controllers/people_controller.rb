##
# Demonstration controller that involves people.
class PeopleController < ApplicationController
  include SoberSwag::Controller

  before_action :load_person, only: %i[show update]

  ##
  # Parameters to create or update a person.
  class ReportingPersonParams < SoberSwag::Reporting::Input::Struct
    identifier 'PersonReportingParams'

    attribute :first_name, SoberSwag::Reporting::Input::Text.new.with_pattern(/.+/)
    attribute :last_name, SoberSwag::Reporting::Input::Text.new.with_pattern(/.+/)
    attribute? :date_of_birth, SoberSwag::Reporting::Input::Converting::DateTime.optional
  end

  ##
  # Parameters to create a person.
  class ReportingPersonCreate < SoberSwag::Reporting::Input::Struct
    identifier 'ReportingPersonCreate'

    attribute :person, ReportingPersonParams
  end

  ##
  # Patch body for a person.
  class ReportingPersonPatchParams < SoberSwag::Reporting::Input::Struct
    identifier 'PersonReportingPatchParams'

    attribute? :first_name, SoberSwag::Reporting::Input.text.with_pattern(/.+/)
    attribute? :last_name, SoberSwag::Reporting::Input.text.with_pattern(/.+/)
    attribute? :date_of_birth, SoberSwag::Reporting::Input::Converting::DateTime.optional
  end

  define :post, :create, '/people/' do
    summary 'Create a person'

    request_body(ReportingPersonCreate)
    response(:ok, 'the person created', PersonOutputObject)
    response(:bad_request, 'the parse errors', SoberSwag::Reporting::Report::Output)
    response(:unprocessable_entity, 'the validation errors', PersonErrorsOutputObject)
    tags 'people', 'create'
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
    summary 'Update a person'

    request_body(reporting: true) do
      attribute :person, ReportingPersonPatchParams
    end
    path_params(reporting: true) { attribute :id, SoberSwag::Reporting::Input::Converting::Integer }
    response(:ok, 'the person updated', PersonOutputObject)
    response(:bad_request, 'the parse errors', SoberSwag::Reporting::Report::Output)
    response(:unprocessable_entity, 'the validation errors', PersonErrorsOutputObject)
    tags 'people', 'update'
  end
  def update
    if @person.update(parsed_body.person.to_h)
      respond!(:ok, @person)
    else
      respond!(:unprocessable_entity, @person.errors)
    end
  end

  define :get, :index, '/people/' do
    summary 'List persons'

    query_params(reporting: true) do
      attribute? :filters do
        attribute? :first_name, SoberSwag::Reporting::Input.text
        attribute? :last_name, SoberSwag::Reporting::Input.text
      end
      attribute? :view, SoberSwag::Reporting::Input.text.enum('base', 'detail')
    end
    response(:ok, 'all the people', PersonOutputObject.list)
    response(:bad_request, 'the parse errors', SoberSwag::Reporting::Report::Output)
    tags 'people', 'list'
  end
  def index
    @people = Person.all
    @people = @people.where('UPPER(first_name) LIKE UPPER(?)', "%#{parsed_query.filters.first_name}%") if parsed_query.filters&.first_name
    @people = @people.where('UPPER(last_name) LIKE UPPER(?)', "%#{parsed_query.filters.last_name}%") if parsed_query.filters&.last_name
    respond!(:ok, @people.includes(:posts), serializer_opts: { view: parsed_query.view || :base })
  end

  define :get, :show, '/people/{id}' do
    summary 'Get a single person by id'

    path_params(reporting: true) do
      attribute :id, SoberSwag::Reporting::Input::Converting::Integer
    end
    response(:ok, 'the person requested', PersonOutputObject)
    response(:bad_request, 'the parse errors', SoberSwag::Reporting::Report::Output)
    tags 'people', 'show'
  end
  def show
    respond!(:ok, @person)
  end

  def load_person
    @person = Person.find(parsed_path.id)
  end
end
