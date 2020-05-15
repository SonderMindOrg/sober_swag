class PeopleController < SoberSwag::Controller

  before_action :load_person, only: %i[show update]

  class PersonBodyParams < Dry::Struct
    attribute :first_name, SoberSwag::Types::String
    attribute :last_name, SoberSwag::Types::String
    attribute? :date_of_birth, SoberSwag::Types::Params::DateTime.optional
  end

  class PersonParams < Dry::Struct
    attribute :person, PersonBodyParams
  end

  define :post, :create, '/people/' do
    body(PersonParams)

    action do
      p = Person.create!(parsed_body.to_h)
      redirect_to p
    end
  end

  define :patch, :update, '/people/{id}' do
    body(PersonParams)
    path_params { attribute :id, Types::Params::Integer }
    action do
      if @person.update(parsed_body.to_h)
        render json: @person
      else
        render json: @person.errors, status: :unprocessable_entity
      end
    end
  end

  define :get, :index, '/people/' do
    query do
      attribute? :first_name, Types::String
      attribute? :last_name, Types::String
    end

    action do
      @people = Person.all
      @people = @people.where('first_name ILIKE ?', "%#{parsed_query.first_name}%") if parsed_query.first_name
      @people = @people.where('last_name ILIKE ?', "%#{parsed_query.last_name}%") if parsed_query.last_name
      render json: @people
    end
  end

  define :get, :show, '/people/{id}' do
    path_params do
      attribute :id, Types::Params::Integer
    end

    action do
      render json: @person
    end
  end

  def load_person
    @person = Person.find(parsed_path.id)
  end
end
