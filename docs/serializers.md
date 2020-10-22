# Serializers

Serializers are a way to transform from one type to another.
For example, you might want to change an ActiveRecord object to a JSON struct.
You might also want to change an internal date-interval into a two-element array of dates, or some custom text format.
You can do all of these things with SoberSwag serializers.
Furthermore, Serializers document the *type* that they serialize, so you can use it to generate documentation.

## The Basics

All serializers are inherited from [`SoberSwag::Serializer::Base`](../lib/sober_swag/serializer/base.rb).
This is an abstract class that implements several methods, most of which will be documented later.
The two that are most interesting, however, are `#type` and `#serialize`.

The first, `#type`, returns a SoberSwag-compatible type definition.
This might be an instance of `SoberSwag::Struct`, or something else.
You'll never need to implement this yourself, but you should note that we generally do not *enforce* these types *at serialization time*.
This might change in the future, likely under a debug flag.

The second, `#serialize`, does the actual work of serialization.
It takes *two arguments*.
The first is the argument that we will transform into the output type.
The second is *always* optional, and is a *hash of options* to use to customize serialization.
For example, you might have a serializer that can return a date in two formats, depending on a boolean flag.
In this case, it might be used as:

```ruby
serializer.new(my_record, { format: :new_style })
```

However, since it is *always* optional, you can also do:

```ruby
serializer.new(my_record)
```

And it *should* pick some default format.

### Primitives

Primitive serializers — or "identity serializers" — are serializers that do nothing.
They are implemented as [`SoberSwag::Serializer::Primitive`](../lib/sober_swag/serializer/primitive.rb), or as the `#primitive` method on an `OutputObject`.
Since they don't do anything, they can be considered the most "basic" serializer.

These serializers *do not* check types.
That is, the following code will not throw an error:

```ruby
serializer = SoberSwag::Serializer::Primitive.new(SoberSwag::Types::String)
serializer.serialize(10) # => 10
```

Thus, care should be used when working with these serializers.
In the future, we might add some "debug mode" thing that will do type-checking and throw errors, however, the cost of doing so in production is probably not worth it.

### Mapped

Sometimes, you can create a serializer via a *proc*.
For example, let's say that I want a serializer that takes a `Date` and returns a String.
I can do this:

```ruby
date_string = SoberSwag::Serializer.primitive(:String).via_map { |d| d.to_s }
```

This is implemented via [`SoberSwag::Serializer::Mapped`](../lib/sober_swag/serializer/mapped.rb).
Basically, it uses your given proc to do serialization.

Once again, this does not do type-checking.
In the future, we might add a debug mode.

### Optional

Oftentimes, we want to give a serializer the ability to serialize `nil` values.
This is often useful in serializing fields.

It turns out that it's pretty easy to make a serializer that can serialize `nil` values: just propogate `nil`s.
For example, let's say I have the following code:

```ruby
Foo = Struct.new(:bar, :baz)
my_serializer.serialize(Foo.new(10, 11)) # => { bar: 10, baz: 11 }
# ^ my_serializer is defined elsewhere
my_serializer.optional.serialize(Foo.new(10, 11)) # => { bar: 10, baz: 11 }
# ^ can serialize the type from before
my_serializer.optional.serialize(nil) # => nil
# ^ nils become nil
```

This properly changes the `type` to be a nilable type, as well.

### Array

Oftentimes, if we have a serializer for a single value, we want to serialize an array of values.
You can use the `#array` method on a serializer to get that.
Continuing our example from earlier:

```ruby
my_serializer.array.serialize([Foo.new(10, 11)]) #=> [{ bar: 10, baz: 11 }]
```

This changes the type properly too.

## OutputObjects

98% of the time, when we're writing web APIs, we want to transform our domain objects into JSON objects.
We often want different ways to do this, too.
Consider, for exmaple, and API for a college.
We might want to provide one detailed way to serialize a student, which includes their full name, grade, student ID, GPA, and so on.
On another page, we might want to display a classroom with a list of students.
However, on the classroom page, we don't want to serialize a full student: that's sending too much data.
Instead, we probably want to serialize a "stub" view.

OutputObjects are the answer to these problems.
They're a way to define a serializer for a JSON object, along with a type, and to define "variant" ways to serialize things.


### The Basics

Let's define an output object:

```ruby
StudentOutputObject = SoberSwag::OutputObject.define do
  field :first_name, primitive(:String)
  field :last_name, primitive(:String)
  field :recent_grades, primitive(:Integer).array do |student|
    student.graded_assignments.limit(100).pluck(:grade)
  end
end
```

We can see a few things here:

1. You define field names with a `field` definition, which is a way to define the serializer for a single field.
2. You must provide types with field names.
3. You can use blocks to do data formatting, which lets you pick different fields and such.


### Multi

If you have a few fields of the same type, you can use `#multi` to define them all at once:

```ruby
StudentOutputObject = SoberSwag::OutputObject.define do
  multi [:first_name, :last_name], primitive(:String)
  field :recent_grades, primitive(:Integer).array do |student|
    student.graded_assignments.limit(100).pluck(:grade)
  end
end
```

This saves a bit of typing, and can help with refactoring later.

### Views

Sometimes, you might want to add "variant" ways to look at data.
We call these "views," based on the output objecter concept.
Let's take a look at their use:

```ruby
StudentOutputObject = SoberSwag::OutputObject.define do
  field :first_name, primitive(:String)
  field :last_name, primitive(:String)
  view :detail do
    field :recent_grades, primitive(:Integer).array do |student|
      student.graded_assignments.limit(100).pluck(:grade)
    end
  end
 end

StudentOutputObject.serialize(my_student) # => { first_name: 'Rich', last_name: 'Evans' }
StudentOutputObject.serialize(
  my_student,
  { view: :detail }
) # => { first_name: 'Rich', last_name: 'Evans', recent_grades: [0, 0, 0, 1] }
```

The options hash of the serializer will be used to determine which view to serialize with.
Handily, each view is actually *its own* serializer.
You can obtain a serializer for a single view very easily:

```ruby
StudentOutputObject.view(:detail)
```

If you want an output object without the view-checking behavior, you can use `.base` on an output object.

```ruby
StudentOutputObject.base
```

Both of these are great for defining *relationships* between data.

### Circular OutputObjects

Sometimes, you might want to include an output object inside another output object, that itself has that output object inside it.
Or, less confusingly, you wanna do this:

```ruby
StudentOutputObject = SoberSwag::OutputObject.define do
  # some other fields
  view :detail do
    field :classes, ClassOutputObject.array
  end
end
```

This can cause a circular dependency.
To break this, you can use a lambda:

```ruby
StudentOutputObject = SoberSwag::OutputObject.define do
  view :detail do
    field :classes, -> { ClassOutputObject.view(:base).array }
  end
end
```

For clarity (and to prevent infinitely-looping serializers on accident, we recommend you *always* use an explicit view for dependent output objects.

### "Inheritance"

Output objects don't support inheritance.
You can't have one output object based on another.
You *can*, however, merge one into another!
Consider this case:

```ruby
GenericBioOutput = SoberSwag::OutputObject.define do
  field :name, primitive(:String)
  field :brief_history, primitive(:String)
end

ExecutiveBioOutput = SoberSwag::OutputObject.define do
  merge GenericBioOutput
  field :company, primitive(:String)
  field :position, primitive(:String)
end
```

Using `#merge` lets you add in all the fields from one output object into another.
You can even use `merge` from within a view.

Note that `merge` does *not* copy anything but fields.
Identifiers and views will not be copied over.

### View Inheritance

While defining a new Output Object, you *do not* have access to the definition of that output object.
So, how do I say that one view should be an extension of another?
Simple, use the `inherits:` kwarg:

```ruby
BioOutput = SoberSwag::OutputObject.define do
  field :name, primitive(:String)

  view :detail do
    field :bio, primitive(:String)
  end

  view :super_detail, inherits: :detail do
    field :age, primitive(:Integer)
  end
end
```

`inherits` will automatically merge in all the fields of the referenced view.
This means that the view `super_detail` will include fields `name`, `bio`, and `age`.
