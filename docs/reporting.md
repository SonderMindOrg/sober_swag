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
  These views *propogate* correctly.
  So if you have views `[:base, :detail]` on a serializer for a person, a serializer for an array of people will have the same views.
- Have a method `view` which takes in an argument, and returns a serializer specialized to that view.
- Have a method `swagger_schema` which converts the node to its swagger schema

From there, everything is done via composition.

