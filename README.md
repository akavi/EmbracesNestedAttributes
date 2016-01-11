# EmbracesNestedAttributes

A library to make using `ActiveRecord.accepts_nested_attributes` even more awesome.

`EmbracesNestedAttributes` is made of several [modules](#modules) that are used by `include`ing them on your `ActiveRecord` model classes.

#### Installation

TODO

#### Compatibility

Currently, only ActiveRecord 3.2 is supported. However, other versions have not been tested and may be compatible.

## Modules

### `AssocOrdering`

Changes the behavior of `accepts_nested_attributes_for` so that the ordering of the passed parameters is persisted.

(Also includes support so the relevant setters persist ordering as well.)

### `AssumeDestroy`

Changes the behavior of `accepts_nested_attributes_for` so that an explicit `_destroy: true` is not required to destroy an association model.

Instead, all models in the association will be destroyed if they are not included in the set of models used to update the association.

### `PolymorphicBuild`

Allows choosing the subclass of a model in an association via a passed `:type` parameter, useful for `accepts_nested_attributes_for` on a polymorphic association.

## Development

Run tests with `rake test`.
