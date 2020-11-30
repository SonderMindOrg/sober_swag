# SoberSwag

![Ruby Test Status](https://github.com/SonderMindOrg/sober_swag/workflows/Ruby/badge.svg?branch=master)
![Linters Status](https://github.com/SonderMindOrg/sober_swag/workflows/Linters/badge.svg?branch=master)

SoberSwag is a combination of [Dry-Types](https://dry-rb.org/gems/dry-types/1.2/) and [Swagger](https://swagger.io/) that makes your Rails APIs more awesome.
Other tools generate documentation from a DSL.
This generates documentation from *types*, which (conveniently) also lets you get supercharged strong-params-on-steroids.

An introductory presentation is available [here](https://www.icloud.com/keynote/0bxP3Dn8ETNO0lpsSQSVfEL6Q#SoberSwagPresentation).

Further documentation on using the gem is available in the `docs/` directory:

- [Serializers](docs/serializers.md)

## Types for a fully-automated API

SoberSwag lets you type your API using describe blocks.
In any controller that includes `SoberSwag::Controller`, you get access to the super-cool DSL method `define`.
This lets you type your API endpoint:

```ruby
class PeopleController < ApplicationController
  include SoberSwag::Controller

  define :patch, :update, '/people/{id}' do
    summary 'Update a Person record.'
    description <<~MARKDOWN
      You can use this endpoint to update a Person record. Note that age cannot
      be a negative integer.
    MARKDOWN

    query_params do
      attribute? :include_extra_info, Types::Params::Bool
    end
    request_body do
      attribute? :name, Types::Params::String
      attribute? :age, Types::Params::Integer
    end
    path_params { attribute :id, Types::Params::Integer }
  end
  def update
    # update action here
  end
end
```

Then we can use the information from our SoberSwag definition *inside* the controller method:

```ruby
def update
  @person = Person.find(parsed_path.id)
  @person.update!(parsed_body.to_h)
end
```

No need for `params.require` or anything like that.
You define the type of parameters you accept, and we reject anything that doesn't fit.

### Rendering Swagger documentation from SoberSwag

We can also use the information from SoberSwag objects to generate Swagger
documentation, available at the `swagger` action on this controller.

You can create the `swagger` action for a controller as follows:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Add a `swagger` GET endpoint to render the Swagger documentation created
  # by SoberSwag.
  resources :people do
    get :swagger, on: :collection
  end

  # Or use a concern to make it easier to enable swagger endpoints for a number
  # of controllers at once.
  concern :swaggerable do
    get :swagger, on: :collection
  end

  resources :people, concerns: :swaggerable do
    get :search, on: :collection
  end

  resources :places, only: [:index], concerns: :swaggerable
end
```

If you don't want the API documentation to show up in certain cases, you can
use an environment variable or a check on the current Rails environment.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :people do
    # Enable based on environment variable.
    get :swagger, on: :collection if ENV['ENABLE_SWAGGER']
    # Or just disable in production.
    get :swagger, on: :collection unless Rails.env.production?
  end
end
```

### Typed Responses

Want to go further and type your responses too?
Use SoberSwag output objects, a serializer library heavily inspired by [Blueprinter](https://github.com/procore/blueprinter)

```ruby
PersonOutputObject = SoberSwag::OutputObject.define do
  field :id, primitive(:Integer)
  field :name, primitive(:String).optional
  # For fields that don't map to a simple attribute on your model, you can
  # use a block.
  field :is_registered, primitive(:Bool) do |person|
    person.registered?
  end
end
```

Now, in your `define` block, you can tell us that this is the *type* of your response:

```ruby
class PeopleController < ApplicationController
  include SoberSwag::Controller
  define :patch, :update, '/people/{id}' do
    request_body do
      attribute? :name, Types::Params::String
      attribute? :age, Types::Params::Integer
    end
    path_params { attribute :id, Types::Params::Integer }
    response(:ok, 'the updated person', PersonOutputObject)
  end
  def update
    person = Person.find(parsed_path.id)
    if person.update(parsed_body.to_h)
      respond!(:ok, person)
    else
      render json: person.errors
    end
  end
end
```

Support for easily typing "render the activerecord errors for me please" is (unfortunately) under development.

### SoberSwag Input Objects

Input parameters (including path, query, and request body) are typed using [dry-struct](https://dry-rb.org/gems/dry-struct/1.0/).
You don't have to do them inline. You can define them in another file, like so:

```ruby
User = SoberSwag.input_object do
  attribute :name, SoberSwag::Types::String
  # use ? if attributes are not required
  attribute? :favorite_movie, SoberSwag::Types::String
  # use .optional if attributes may be nil
  attribute :age, SoberSwag::Types::Params::Integer.optional
end
```

Then, in your controller, just do:

```ruby
class PeopleController < ApplicationController
  include SoberSwag::Controller

  define :path, :update, '/people/{id}' do
    request_body(User)
    path_params { attribute :id, Types::Params::Integer }
    response(:ok, 'the updated person', PersonOutputObject)
  end
  def update
    # same as above!
  end
end
```

Under the hood, this literally just generates a subclass of `Dry::Struct`.
We use the DSL-like method just to make working with Rails' reloading less annoying.

#### Nested object attributes

You can nest attributes using a block. They'll return as nested JSON objects.

```ruby
User = SoberSwag.input_object do
  attribute :user_notes do
    attribute :note, SoberSwag::Types::String
  end
end
```

If you want to use a specific type of object within an input object, you can
nest them by setting the other input object as the type of an attribute. For
example, if you had a UserGroup object with various Users, you could write
them like this:

```ruby
User = SoberSwag.input_object do
  attribute :name, SoberSwag::Types::String
  attribute :age, SoberSwag::Types::Params::Integer.optional
end

UserGroup = SoberSwag.input_object do
  attribute :name, SoberSwag::Types::String
  attribute :users, SoberSwag::Types::Array.of(User)
end
```

#### Input and Output Object Identifiers

Both input objects and output objects accept an identifier, which is used in
the Swagger Documentation to disambiguate between SoberSwag types.

```ruby
User = SoberSwag.input_object do
  identifier 'User'

  attribute? :name, SoberSwag::Types::String
end
```

```ruby
PersonOutputObject = SoberSwag::OutputObject.define do
  identifier 'PersonOutput'

  field :id, primitive(:Integer)
  field :name, primitive(:String).optional
end
```

You can use these to make your Swagger documentation a bit easier to follow,
and it can also be useful for 'namespacing' objects if you're developing in
a large application, e.g. if you had a pet store and for some reason users
with cats and users with dogs were different, you could namespace it with
`identifier 'Dogs.User'`.

#### Adding additional documentation

You can use the `.meta` attribute on a type to add additional documentation.
Some keys are considered "well-known" and will be present on the swagger output.
For example:


```ruby
User = SoberSwag.input_object do
  attribute? :name, SoberSwag::Types::String.meta(description: <<~MARKDOWN, deprecated: true)
    The given name of the students, with strings encoded as escaped-ASCII.
    This is used by an internal Cobol microservice from 1968.
    Please use unicode_name instead unless you are that microservice.
  MARKDOWN
  attribute? :unicode_name, SoberSwag::Types::String
end
```

This will output the swagger you expect, with a description and a deprecated flag.

#### Adding Default Values

Sometimes it makes sense to specify a default value.
Don't worry, we've got you covered:

```ruby
QueryInput = SoberSwag.input_object do
  attribute :allow_first, SoberSwag::Types::Params::Bool.default(false) # smartly alters type-definition to establish that passing this is not required.
end
```

## Tags

If you want to organize your API into sections, you can use `tags`.
It's quite simple:

```ruby
define :patch, :update, '/people/{id}' do
  # other cool config
  tags 'people', 'mutations', 'incurs_cost'
end
```

This will map to OpenAPI's `tags` field (naturally), and the UI codegen will automatically organize your endpoints by their tags.

## Testing the validity of output objects

If you're using RSpec and want to test the validity of output objects, you can do so relatively easily.

For example, assuming that you have a `UserOutputObject` class for representing a User record, and you have a `:user` factory via FactoryBot, you can validate that the serialization works without error like so:

```ruby
RSpec.describe UserOutputObject do
  describe 'serialized result' do
    subject do
      described_class.type.new(described_class.serialize(create(:user)))
    end

    it 'works with an object' do
      expect { subject }.not_to raise_error
    end
  end
end
```

## Special Thanks

This gem is a mishmash of ideas from various sources.
The biggest thanks is owed to the [dry-rb](https://github.com/dry-rb) project, upon which the typing of SoberSwag is based.
On an API design level, much is owed to [blueprinter](https://github.com/procore/blueprinter) for the serializers.
The idea of a strongly-typed API came from the Haskell framework [servant](https://www.servant.dev/).
Generating the swagger documentation happens via the use of a catamorphism, which I believe I first really understood thanks to [this medium article by Jared Tobin](https://medium.com/@jaredtobin/practical-recursion-schemes-c10648ec1c29).
