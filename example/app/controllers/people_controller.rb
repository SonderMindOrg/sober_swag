class PeopleController < SoberSwag::Controller

  before_action :load_person, only: %i[show update]

  unless defined?(PersonBodyParams)
    class PersonBodyParams < Dry::Struct
      attribute :first_name, SoberSwag::Types::String
      attribute :last_name, SoberSwag::Types::String
      attribute? :date_of_birth, SoberSwag::Types::Params::DateTime.optional
    end
  end

  unless defined?(PersonParams)
    class PersonParams < Dry::Struct
      attribute :person, PersonBodyParams
    end
  end

  unless defined?(PersonSerializer)
    PersonSerializer = SoberSwag::Blueprint.define do
      field :id, primitive(:Integer)
      field :first_name, primitive(:String)
      field :last_name, primitive(:String)
    end
  end

  define :post, :create, '/people/' do
    request_body(PersonParams)

    action do
      p = Person.create!(parsed_body.to_h)
      respond!(:ok, p)
    end

    response(:ok, 'the person created', PersonSerializer)
  end

  define :patch, :update, '/people/{id}' do
    request_body(PersonParams)
    path_params { attribute :id, Types::Params::Integer }
    response(:ok, 'the person updated', PersonSerializer)
    action do
      if @person.update(parsed_body.to_h)
        respond!(:ok, @person)
      else
        render json: @person.errors, status: :unprocessable_entity
      end
    end
  end

  define :get, :index, '/people/' do
    query_params do
      attribute? :first_name, Types::String
      attribute? :last_name, Types::String
    end

    response(:ok, 'all the people', PersonSerializer.new.array)

    action do
      @people = Person.all
      @people = @people.where('first_name ILIKE ?', "%#{parsed_query.first_name}%") if parsed_query.first_name
      @people = @people.where('last_name ILIKE ?', "%#{parsed_query.last_name}%") if parsed_query.last_name
      respond!(:ok, @people)
    end
  end

  define :get, :show, '/people/{id}' do
    path_params do
      attribute :id, Types::Params::Integer
    end

    response(:ok, 'the person requested', PersonSerializer.new)

    action do
      respond!(:ok, @person)
    end
  end

  def load_person
    @person = Person.find(parsed_path.id)
  end
end
