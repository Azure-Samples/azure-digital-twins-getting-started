# Changes made between basic and advanced

- [Semantic Types](#semantic-types)
- [Complex Types (Object)](#complex-type)
- [Inheritance](#inheritance)
- [Relationship properties](#relationship-properties)
- [Non-targeted relationship](#non-targeted-relationship)

## Semantic Types

In the `Room` model, both the Humidty property and Temperature telemetry are semantic type (from basic double).

<img src="../../images/adv-home-semantic-properties.png" style="max-width: 400px" alt="screen shot of semantic types dtdl example" />
...
<img src="../../images/adv-home-semantic-telemtry.png" style="max-width: 400px" alt="screen shot of semantic types dtdl example" />

## Complex Type

Added a new address complex type to collect address information on the `Home` model.

<img src="../../images/adv-home-object.png" style="max-width: 400px" alt="screen shot of a complex type dtdl example" />

## Inheritance
Added the ICore.json to include an id and name. 

<img src="../../images/adv-home-core.png" style="max-width: 400px" alt="screen shot of inheritance dtdl example" />

The `dtmi:com:adt:dtsample:core;1` is extended by the `Home`, `Floor`, and `Room` models.

<img src="../../images/adv-home-inheritance.png" style="max-width: 400px" alt="screen shot of inheritance extended dtdl example" />

## Relationship Properties

Relationship `dtmi:com:adt:dtsample:home:rel_has_floors;1` on the `Home` model has a newly added property.

<img src="../../images/adv-home-rel.png" style="max-width: 400px" alt="screen shot of relationship properties dtdl example" />

## Non-Targeted Relationship

Removed the target property on the `dtmi:com:adt:dtsample:room:rel_has_sensors;1` on the `Room` model.

<img src="../../images/adv-home-nontarget.png" style="max-width: 400px" alt="screen shot of non-targeted relationship dtdl example" />