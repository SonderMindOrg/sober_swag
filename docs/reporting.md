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
This is intended to be used to make writing specs easier: to check that your serializer gives the right types, just use it in reporting mode and check the value!

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
Views can be nested only once - if you use a serializer with views as the key of an object, we will *always* use the base view.
This prevents some weirdness with the non-reporting SoberSwag serializers, where views could technically be read by child objects in some circumstances as they were only passed in the `view` key.
A view will *always inherit all attributes of the parent object, regardless of order.*

```ruby
class AlternativePersonOutput < SoberSwag::Output::Struct
  field :first_name, SoberSwag::Reporting::Output.text

  define_view :with_grade do
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

## API Overview

This section presents an overview of the available reporting outputs and inputs.

### `SoberSwag::Reporting::Output`

This module contains reporting *outputs*.
These act as type-checked serializers.

#### Primitive Types

The following "primitive types" are available:

- `SoberSwag::Reporting::Output.bool`, which returns a `SoberSwag::Reporting::Output::Bool`.
  This type is for serializing boolean values, IE, `true` or `false`.
  It will serialize the boolean directly to the JSON.
- `SoberSwag::Reporting::Output.null`, which returns a `SoberSwag::Reporting::Output::Null`.
  This type serializes out `null` in JSON.
  This can only serialize the ruby value `nil`.
- `SoberSwag::Reporting::Output.number`, returns a `SoberSwag::Reporting::Output::Number`.
  This type serializes out numbers in JSON.
  It can serialize out most ruby numeric types, including `Integer` and `Float`.
- `SoberSwag::Reporting::Output.text`, which returns a `SoberSwag::Reporting::Output::Text`.
  This serializes out a string type in the JSON.
  It can serialize out ruby strings.

### The Transforming Type

For `SoberSwag::Reporting::Output`, there's a "fundamental" type that does *transformation*, called `via_map`.
It lets you apply a ruby block before passing the input on to the serializer after it.
It's most often used like this:

```ruby
screaming_output = SoberSwag::Reporting::Output.text.via_map { |old_text| old_text.upcase }
screaming_output.call("what the heck")
# => "WHAT THE HECK"
```

Note that this calls the block *before* passing to the next serializer.
So:

```ruby
example = SoberSwag::Reporting::Output.text.via_map { |x| x.downcase }.via_map { |x| x + ", OK?" }
example.call("WHAT THE HECK?")
# => "what the heck, ok?"
```

This type winds up being extremely useful in a *lot* of places.
That's why it gets its own section!

#### Composite Types

The following "composite types," or types built from other types, are available:

- `SoberSwag::Reporting::Output::List`, which seralizes out *lists* of values.
  You can construct one in two ways:

  ```ruby
  SoberSwag::Reporting::Output::List.new(SoberSwag::Reporting::Output.text)
  # or, via the instance method
  SoberSwag::Reporting::Output.text.list
  ```
  This produces an output that can serialize to JSON arrays.
  For example, either of these can produce:

  ```json
  ["foo", "bar"]
  ```

  This serialize will work with anything that responds to `#map`.

- `SoberSwag::Reporting::Output::Dictionary`, which can be constructed via:
  ```ruby
  `SoberSwag::Reporting::Output::Dictionary.of(SoberSwag::Reporting::Output.number)
  ```

  This type serializes out a key-value dictionary, IE, a JSON object.
  So, the above can serialize:
  ```ruby
  { "foo": 10, "bar": 11 }
  ```
  This type will only serialize out ruby hashes.
  It will, conveniently, convert symbol keys to strings for you.

- `SoberSwag::Reporting::Output::Partitioned`, which represents the *choice* of two serializers.
  It takes in a block to decide which serializer to use, a serializer to use if the block returns `true`, and a serializer to use if the block returns `false`.
  That is, to serialize out *either* a string *or* a number, you might use:
  ```ruby
  SoberSwag::Reporting::Output::Partitioned.new(
    proc { |x| x.is_a?(String) },
    SoberSwag::Reporting::Output.text,
    SoberSwag::Reporting::Output.number
  )
  ```
- `SoberSwag::Reporting::Output::Viewed`, which lets you define a *view map* for an object.
  This is mostly used as an implementation detail, but can be occasionally useful if you want to provide
  a list of "views" with no common "base," like an output object might have. In this case, the "base"
  view is more of a "default" rather than a "parent."

### Validation Types

OpenAPI v3 supports some *validations* on types, in addition to raw types.
For example, you can specify in your documentation that a value will be within a *range* of values.
These `SoberSwag::Reporting::Output` types provide that documentation - and perform those validations!

- `SoberSwag::Reporting::Output::InRange` validates that a value will be within a certain *range* of values.
  This is most useful with numbers.
  For example:
  ```ruby
  SoberSwag::Reporting::Output.number.in_range(0..10)
  ```
- `SoberSwag::Reporting::Output::Pattern` validates that a value will match a certain *pattern.*
  This is useful with strings:
  ```ruby
  SoberSwag::Reporting::Output::Pattern.new(SoberSwag::Reporting::Output.text, /foo|bar|baz|my-[0-5*/)
  ```

## `SoberSwag::Reporting::Input`

This module is used for *parsers*, which take in some input and return a nicer type.

### Basic Types

These types are the "primitives" of `SoberSwag::Reporting::Input`, the most basic types:

- `SoberSwag::Reporting::Input::Null` parses a JSON `null` value.
  It will parse it to a ruby `nil`, naturally.
  You probably want to construct one via `SoberSwag::Reporting::Input.null`.
- `SoberSwag::Reporting::Input::Number` parses a JSON number.
  It will parse to either a ruby `Integer` or a ruby `Float`, depending on the format (we use Ruby's internal format for this).
  You probably want to construct one via `SoberSwag::Reporting::Input.number`.
- `SoberSwag::Reporting::Input::Bool`, which parses a JSON bool (`true` or `false`).
  This will parse to a ruby `true` or `false`.
  You probably want to construct it with `SoberSwag::Reporting::Output.bool`.
- `SoberSwag::Reporting::Input::Text`, which parses a JSON string (`"mike stoklassa"`, `"richard evans"`, or `"jay bauman"` for example).
  This will parse to a ruby string.
  You probably want to construct it with `SoberSwag::Reporting::Output.text`.

### The Transforming Type

Much like `via_map` for `SoberSwag::Reporting::Output`, there's a fundmantal type that does *transformation*, called the `mapped`.
This lets you do some transformation of input *after* others have ran.
So:

```ruby
quiet = SoberSwag::Reporting::Input.text.mapped { |x| x.downcase }
quiet.call("WHAT THE HECK")
# => "what the heck"
```

Note that this composes as follows:

```ruby
example = SoberSwag::Reporting::Input.text.mapped { |x| x.downcase }.mapped { |x| x + ", OK?" }

example.call("WHAT THE HECK")
# => "what the heck, OK?"
# As you can see, the *first* function applies first, then the *second*.
```

You might notice that this is the opposite behavior of of `SoberSwag::Reporting::Output::ViaMap`.
This is because *serialization* is the *opposite* of *parsing*.
Kinda neat, huh?

### Composite Types

These types work with *one or more* inputs to build up *another*.

- `SoberSwag::Reporting::Input::List`, which lets you parse a JSON array.
  IE:
  ```ruby
  SoberSwag::Reporting::Input::List.of(SoberSwag::Reporting::Input.number)
  ```
  Lets you parse a list of numbers.
- `SoberSwag::Reporting::Input::Either`, which lets you parse one input, and if that fails, parse another.
  This represents a *choice* of input types.
  This is best used via:
  ```ruby
  SoberSwag::Reporting::Input.text | SoberSwag::Reporting::Input.number
  # or
  SoberSwag::Reporting::Input.text.or SoberSwag::Reporting::Input.number
  ```
  This is useful if you want to allow multiple input formats.
- `SoberSwag::Reporting::Input::Dictionary`, which lets you parse a JSON dictionary with arbitrary keys.
  For example, to parse this JSON (assuming you don't know the keys ahead of time):
  ```json
  {
    "mike": 100,
    "bob": 1000,
    "joey": 12,
    "yes": 1213
  }
  ```
  You can use:
  ```ruby
  SoberSwag::Reporting::Input::Dictionary.of(SoberSwag::Reporting::Input.number)
  ```

  This will parse to a Ruby hash, with string keys.
  If you want symbols, you can simply use `.mapped`:
  ```ruby
  SoberSwag::Reporting::Input::Dictionary.of(
    SoberSwag::Reporting::Input.number
  ).mapped { |hash| hash.transform_keys(&:to_sym) }
  ```
  Pretty cool, right?
- `SoberSwag::Reporting::Input::Enum`, which lets you parse an *enum value*.
  This input will validate that the given value is in the enum.
  Note that this doesn't only work with strings!
  You can use:

  ```ruby
  SoberSwag::Reporting::Input.number.enum(-1, 0, 1)
  ```

  And things will work fine.
