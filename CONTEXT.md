# Timezone-Aware Date Parsing

This package models date-time values that retain explicit timezone semantics.
Its parsing vocabulary distinguishes exact numeric offsets from IANA regions,
while its public values remain compatible with Dart's `DateTime` contract.

## Language

**DateTime-compatible enhancement**:
An additive value that can be supplied to APIs accepting `DateTime`, while
offering explicit timezone and calendar semantics. Dart extension dispatch
still follows the static receiver type.
_Avoid_: new temporal type system, `DateTime` fork

**Instant-preserving conversion**:
Viewing one instant in a different IANA location, which changes local fields as
needed while retaining the same point on the timeline.
_Avoid_: timezone rewrite, local-field relocation

**Local-field relocation**:
Creating a value in another IANA location from the same calendar and clock
fields; it can represent a different instant.
_Avoid_: timezone conversion, instant-preserving conversion

**Configured local location**:
The explicitly configured local location used for Dart-style local operations;
it is distinct from a convenience default location and is not device detection.
_Avoid_: system timezone, default location

**Local-time resolution**:
The explicit rule that maps a local date-time to an instant when a DST gap or
overlap has zero or multiple valid results.
_Avoid_: DST fallback, automatic timezone choice

**Parse policy**:
The explicit combination of validation mode and offset-resolution strategy used
to interpret a date-time string.
_Avoid_: parsing options, parser configuration

**Fixed offset location**:
A synthetic timezone location identified only by its UTC offset, such as
`UTC+08:00`; it does not imply an IANA region.
_Avoid_: timezone region, inferred location

**Region resolution**:
The parsing strategy that maps an offset-bearing input to a matching IANA
timezone location when possible.
_Avoid_: fixed offset resolution

**Parse diagnostics**:
Structured metadata that records the effective parse policy and the stage at
which a parse attempt failed.
_Avoid_: parse error text, failure message

**Fixed-offset round trip**:
Serializing an offset-bearing value to ISO 8601 and parsing it again with the
fixed offset policy preserves its numeric offset as the location identity.
_Avoid_: region inference round trip
