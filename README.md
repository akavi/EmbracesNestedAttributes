# ActiveRecordEx

A library to make `ActiveRecord::Relation`s even more awesome.

[![Build Status](https://travis-ci.org/PagerDuty/active-record-ex.svg?branch=master)](https://travis-ci.org/PagerDuty/active-record-ex)

`ActiveRecordEx` is made of several [modules](#modules) that are used by `include`ing them on your `ActiveRecord` model classes.

#### Compatibility

Currently, only ActiveRecord 3.2 with Ruby 2.1 is supported. However, other versions have not been tested and may be compatible.

## Modules

### `AssocOrdering`

Extends setters for `has_many` associations so that ordering of association arrays is persisted.

## Development

Run tests with `rake test`.
