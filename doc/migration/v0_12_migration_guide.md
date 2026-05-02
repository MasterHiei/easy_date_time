# V0.12 Migration Guide

This guide covers migration from pre-v0.12 parsing behavior to the v0.12 policy model.

## Summary

v0.12 introduces explicit parse policy controls:

- `EasyParseMode`
- `OffsetResolution`
- `EasyParseOptions`

It also deprecates the boolean `strict` parameter in favor of `options`.

## `strict` to `options`

### Before

```dart
EasyDateTime.parse(input, strict: false);
EasyDateTime.parse(input, strict: true);
EasyDateTime.tryParse(input, strict: true);
```

### After

```dart
EasyDateTime.parse(
  input,
  options: const EasyParseOptions(mode: EasyParseMode.compatible),
);

EasyDateTime.parse(
  input,
  options: const EasyParseOptions(mode: EasyParseMode.isoStrict),
);

EasyDateTime.tryParse(
  input,
  options: const EasyParseOptions(mode: EasyParseMode.isoStrict),
);
```

## Offset behavior

### Old default behavior

Offset values were commonly resolved via region inference (for example `+09:00` to an IANA location).

### v0.12 explicit behavior

Use `OffsetResolution.fixed` to preserve the exact offset as a synthetic `UTC±HH:MM` location.

```dart
final dt = EasyDateTime.parse(
  '2026-01-18T10:30:00+08:00',
  options: const EasyParseOptions(
    mode: EasyParseMode.compatible,
    offsetResolution: OffsetResolution.fixed,
  ),
);

print(dt.locationName); // UTC+08:00
```

Use `OffsetResolution.region` when you need region inference semantics.

```dart
final dt = EasyDateTime.parse(
  '2026-01-18T10:30:00+08:00',
  options: const EasyParseOptions(
    mode: EasyParseMode.compatible,
    offsetResolution: OffsetResolution.region,
  ),
);
```

## Recommended migration patterns

- Keep existing behavior first: migrate `strict` to `options` without changing `mode` expectations.
- Adopt `isoStrict` only for endpoints that require strict calendar validation.
- Adopt `fixed` for APIs where offset fidelity is more important than inferred IANA region names.
- Add tests for DST overlap/gap and uncommon offsets (`+12:45`, `-09:30`, `+05:45`).

## Failure diagnostics

v0.12 adds parse diagnostics metadata through `InvalidDateFormatException` and offset resolution failures.
Use this metadata for debugging and API error reporting.

