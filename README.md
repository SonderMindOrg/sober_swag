# SoberSwag

![Ruby Test Status](https://github.com/SonderMindOrg/sober_swag/workflows/Ruby/badge.svg?branch=master)

***NOTE: THIS GEM IS HIGHLY EXPERIMENTAL AND PROBABLY SHOULD NOT YET BE USED IN PRODUCTION***.

SoberSwag is a combination of [Dry-Types](https://dry-rb.org/gems/dry-types/1.2/) and [Swagger](https://swagger.io/) that makes your Rails APIs more awesome.
Other tools generate documenation from a DSL.
This generates documentation from *types*, which (conveniently) also lets you get supercharged strong-params-on-steroids.

This gem uses pattern matching, and is thus only compatible with Ruby 2.7 or later.

## Types for a fully-automated API

SoberSwag lets you type your API using describe blocks.
In any controller that includes `SoberSwag::Controller`, you get access to the super-cool DSL method `define`.
This lets you type your API endpoint:

```ruby
  class PeopleController < ApplicationController
    include SoberSwag::Controller
    define :patch, :update, '/people/{id}' do
      query_params do
        attribute? :include_extra_info, Types::Params::Bool
      end
      request_body do
        attribute? :name, Types::Params::String
        attribute? :age, Types::Params::Integer
      end
      path_params { attribute :id, Types::Params::Integer }
    end
  end
```

We can now us this information to generate swagger documentation, available at the `swagger` action on this controller.
More than that, we can use this information *inside* our controller methods:

```ruby
def update
  @person = Person.find(parsed_path.id)
  @person.update!(parsed_body.to_h)
end
```

No need for `params.require` or anything like that.
You define the type of parameters you accept, and we reject anything that doesn't fit.

### Typed Responses

Want to go further and type your responses too?
Use SoberSwag blueprints, a serializer library heavily inspired by [Blueprinter](https://github.com/procore/blueprinter)

```ruby
PersonBlueprint = SoberSwag::Blueprint.define do
  field :id, primitive(:Integer)
  field :name, primitive(:String).optional
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
    response(:ok, 'the updated person', PersonBlueprint.new)
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

### SoberSwag Structs

Input parameters (including path, query, and request body) are typed using [dry-struct](https://dry-rb.org/gems/dry-struct/1.0/).
You don't have to do them inline: you can define them in another file, like so:

```ruby
User = SoberSwag.struct do
  attribute :name, SoberSwag::Types::String
  # use ? if attributes are not required
  attribute? :favorite_movie, SoberSwag::Types::String
  # use .optional if attributes may be null
  attribute :age, SoberSwag::Types::Params::::Integer.optional
end
```

Under the hood, this literally just generates a subclass of `Dry::Struct`.
We use the DSL-like method just to make working with Rails' reloading less annoying.

## Special Thanks

This gem is a mismatch of ideas from various sources.
The biggest thanks is owed to the [dry-rb](https://github.com/dry-rb) project, upon which the typing of SoberSwag is based.
On an API design level, much is owed to [blueprinter](https://github.com/procore/blueprinter) for the serializers.
The idea of a strongly-typed API came from the Haskell framework [servant](https://www.servant.dev/).
Generating the swagger documenation happens via the use of a catamorphism, which I believe I first really understood thanks to [this medium article by Jared Tobin](https://medium.com/@jaredtobin/practical-recursion-schemes-c10648ec1c29).
