# Changelog

## Unreleased

- Add `multi` to Output Objects, as a way to define more than one field of the same type at once.
- Add an `inherits:` key to output objects, for view inheritance.
- Add `SoberSwag::Types::CommaArray`, which parses comma-separated strings into arrays.
  This also sets `style` to `form` and `explode` to `false` when generating Swagger docs.
  This class is mostly useful for query parameters where you want a simpler format: `tag=foo,bar` instead of `tag[]=foo,tag[]=bar`.
- Add support for using `meta` to specify alternative `style` and `explode` keys for query and path params.
  Note that this support *does not* extend to parsing: If you modify the `style` or `explode` keywords, you will need to make those input formats work with the actual type yourself.
