# Changes made between basic and advanced

- [Semantic Types](#semantic-types)
- [Complex Types (Object)](#complex-type)
- [Inheritance](#inheritance)
- [Relationship properties](#relationship-properties)
- [Non-targeted relationship](#non-targeted-relationship)

## Semantic Types

In the `ISensor` model, both the Humidity and Temperature properties are semantic type (from basic double).

The same is true for the `IRoom` model's Humidity property.

## Complex Type

Added a new address complex type to collect address information on the `IHome` model.

## Inheritance

Added the `ICore.json` to include an ID and name.

The `dtmi:com:adt:dtsample:core;1` is extended by the `IHome`, `IFloor`, and `IRoom` models.

## Relationship Properties

Relationship `dtmi:com:adt:dtsample:home:rel_has_floors;1` on the `IHome` model has a newly added property.

## Non-Targeted Relationship

Removed the target property on the `dtmi:com:adt:dtsample:room:rel_has_sensors;1` on the `IRoom` model.
