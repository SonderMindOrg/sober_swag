# SoberSwag Reporting

`SoberSwag::Reporting` is a new module that provides a more *composable* interface of sober swag types.
Unlike the base version, it is *not* based on `dry-types`, instead using a simpler scheme.
It also allows for modeling of more complex type domains, and more reusable types.

The module is called `SoberSwag::Reporting` because it *reports* what happened on failure.
Consider trying to parse a struct with a first and last name, both of which need to be non-empty strings.
If I give it this input:

```json
{
  "first_name": 10,
  "last_name": ""
}
```

I will get back a report, which can tell me:

```json
{
  "$.first_name": ["must be a string"],
  "$.last_name": ["does not match pattern (.+)"]
}
```

As you can see, we get a dictionary of JSON-path values to errors.

More interestingly, you can use serializers in "reporting mode," which will *verify* that you're actually serializing what you said you would.
If you mess up, it'll give you a report of where the errors were.

## Basic Design

SoberSwag's reporting module is designed from the ground up to be *node-based*.
Everything conforms to a common interface.
For reporting *inputs*, all values:

- Have a method `call` which converts an input to the desired format, or a report if there was an error
- Have a method `call!` which converts an input to the desired format, or raises an exception if there was an error
- Have a method `swagger_schema` which converts the node to its swagger schema.


For reporting *outputs*, all values:

- Have a method `call` which serializes out a value
- Have a method `serialize_report` which serializes in "reporting mode," IE, it will return a report if serialization happened improperly
- Have a method `views` which returns a *set of applicable views*.
  This is used to implement a serializer with many alternatives.
  These views *propagate* correctly.
  So if you have views `[:base, :detail]` on a serializer for a person, a serializer for an array of people will have the same views.
- Have a method `view` which takes in an argument, and returns a serializer specialized to that view.
- Have a method `swagger_schema` which converts the node to its swagger schema

From there, everything is done via composition.
Nodes delegate to other nodes to provide functionality like "wrap this type in a common reference" and "validate that this string matches this regexp."
Currently, the only validator built-in is matching a regexp or being a member of an enum, but we may add more in the future.
You can also use `.mapped` to do custom validation:

```ruby
NotTheStringBob = SoberSwag::Reporting::Input.text.mapped do |text|
  if text == "Bob"
    Report::Value.new(['was the string bob I specifically told you not to be the string bob'])
  else
    text
  end
end
```

## Input Structs

SoberSwag's reporting mode includes a class called `SoberSwag::Reporting::Input::Struct`.
It can be used to model *struct inputs*, IE, inputs that have some properties and are represented by JSON objects.

These structs behave much like Ruby structs, and implement inheritance *correctly*.
This means that the following works:

```ruby
class Person < SoberSwag::Reporting::Input::Struct
  attribute :first_name, SoberSwag::Reporting::Input.text
  attribute :last_name, SoberSwag::Reporting::Input.text
end

class GradedPerson < Person
  attribute :grade, SoberSwag::Reporting::Input.text.enum('A', 'B', 'C', 'D', 'F')
end
```

## Output Structs

SoberSwag's Reporting Output Structs work much the same way.
You can define *fields* on them, which they will serialize.
You can use them to define how to serialize an object, like so:

```ruby
class PersonOutput < SoberSwag::Output::Struct
  field :first_name, SoberSwag::Reporting::Output.text
  field :last_name, SoberSwag::Reporting::Output.text

  field :grade, SoberSwag::Reporting::Output.text.nilable do
    if object_to_serialize.respond_to?(:grade)
      object_to_serialize.grade
    else
      nil
    end
  end

  field :has_grade, SoberSwag::Reporting::Output.bool do
    grade.nil? # fields are defined as *methods* on the output struct
  end
end
```

Output Structs can also have *views*.
Views can be nested only once.
A view will *always inherit all attributes of the parent object, regardless of order.*

```ruby
class AlternativePersonOutput < SoberSwag::Output::Struct
  field :first_name, SoberSwag::Reporting::Output.text

  view :with_grade do
    field :grade, SoberSwag::Reporting::Output.text.nilable do
      if object_to_serialize.respond_to?(:grade)
        object_to_serialize.grade
      else
        nil
      end
    end
  end

  field :last_name, SoberSwag::Reporting::Output.text
end

AlternativePersonOutput.views # => Set.new(:base, :with_grade)
AlternativePersonOutput.view(:with_grade).serialize(my_person) # includes the last_name field
```

View relationships are modeled with *composition*.
This leads to slightly more natural to read swagger schemas.

## Dictionary Types

SoberSwag's reporting outputs allow defining a *dictionary* of key-value types.
This lets you represent an object like this in your schema:

```json
{
  "name": "Advanced Time Travel",
  "student_grades": {
    "student_id_1": "F",
    "student_id_2": "F"
  }
}
```

This type would probably be represented by:

```ruby
class Classroom < SoberSwag::Reporting::Input::Struct
  attribute :name, SoberSwag::Reporting::Input.text
  attribute :student_grades, SoberSwag::Reporting::Input::Dictionary.of(
    SoberSwag::Reporting::Input.text.enum('A', 'B', 'C', 'D', 'F')
  )
end
```

## Referenced Types

If you have a type you use a lot, and you want to refer to it by a common name, you can describe it like so:

```ruby
GradeEnum = SoberSwag::Reporting::Input.text.enum('A', 'B', 'C', 'D', 'F').referenced('GradeEnum')
```

This will now be represented as a Reference type in generated swagger.

## Things not present

There are basically two things to keep in mind when upgrading to `SoberSwag::Reporting`.

1. There is no longer a `default` for a type.
   This is because that was really hard to model in Swagger, and can be better served via use of `.mapped` and `.optional`.
   We may add this back eventually.
2. Serializers no longer take an arbitrary `options` key.
   Instead, view management is now *explicit*.
   This is because it was too tempting to pass data to serialize in the options key, which is against the point of the serializers.


