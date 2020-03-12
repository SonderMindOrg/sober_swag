class PeopleController < SoberSwag::Controller

  define :post, :create, '/people/' do
    body do
      attribute :first_name, Types::String
      attribute :last_name, Types::String
      attribute? :date_of_birth, Types::Params::DateTime.optional
    end

    action do
      p = Person.create!(parsed_body.to_h)
      redirect_to p
    end
  end
end
