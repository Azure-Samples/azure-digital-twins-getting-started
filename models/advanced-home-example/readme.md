# Changes made between basic and advanced

- [Semantic Types](#semantic-types)
- [Complex Types (Object)](#complex-type)
- [Inheritance](#inheritance)
- [Relationship properties](#relationship-properties)
- [Non-targeted relationship](#non-targeted-relationship)

## Semantic Types

Both humidty and temperature are semantic type (from basic double).

<img src="../../images/adv-home-semantic.png" style="max-width: 400px" />

## Complex Type

Added a new address complex type to collect address information on the `Home` model.

<img src="../../images/adv-home-object.png" style="max-width: 400px" />

## Inheritance
Added the ICore.json to include an id and name. 

<img src="../../images/adv-home-core.png" style="max-width: 400px" />

The `dtmi:com:adt:dtsample:core;1` is extended by the `Home`, `Floor`, and `Room` models.

<img src="../../images/adv-home-inheritance.png" style="max-width: 400px" />

## Relationship Properties

Relationship `dtmi:com:adt:dtsample:home:rel_has_floors;1` on the `Home` model has a newly added property.

<img src="../../images/adv-home-rel.png" style="max-width: 400px" />

## Non-Targeted Relationship

Removed the target property on the `dtmi:com:adt:dtsample:room:rel_has_sensors;1` on the `Room` model.

<img src="../../images/adv-home-nontarget.png" style="max-width: 400px" />