# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

A `DateTime`-compatible API for Dart and Flutter with explicit IANA timezone handling and deterministic parse policies.

## Why this package

Dart `DateTime.parse()` normalizes offset inputs to UTC. In timezone-heavy applications, this often changes the wall-clock value that users entered.

```dart
DateTime.parse('2026-01-18T10:30:00+08:00').hour;    // 2
EasyDateTime.parse('2026-01-18T10:30:00+08:00').hour; // 10
```

`easy_date_time` keeps `DateTime` API compatibility while making timezone behavior explicit.

## Documentation

- [Migration guide](docs/migration/v0_12_migration_guide.md)
- [API reference](https://pub.dev/documentation/easy_date_time/latest/)
- [Contribution guide](CONTRIBUTING.md)

## Installation

Stable release on pub.dev:

```yaml
dependencies:
  easy_date_time: ^0.12.0
```

## Requirements

- Dart SDK: `>=3.10.0 <4.0.0`
- Initialize timezone data once before timezone-aware operations

```dart
import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();
}
```

## Quick start

```dart
final source = EasyDateTime.parse('2026-01-18T10:30:00+08:00');
final ny = source.inLocation(TimeZones.newYork);

print(source.hour);          // 10
print(source.locationName);  // UTC+08:00 in fixed mode
print(ny.locationName);      // America/New_York
```

## Parse policy model

### Parse mode

| Mode | Purpose | Behavior |
|---|---|---|
| `legacy` | Preserve historical behavior | Region-based offset resolution |
| `compatible` | Default when explicit `options` are passed | Permissive parsing with normalization |
| `isoStrict` | Enforce strict validation | Rejects calendar overflow and strict-invalid inputs |

### Offset resolution

| Strategy | Resulting location | Typical use |
|---|---|---|
| `OffsetResolution.fixed` | Synthetic `UTC±HH:MM` | Preserve exact offset identity |
| `OffsetResolution.region` | IANA location lookup result | Prefer regional timezone semantics |

```dart
final dt = EasyDateTime.parse(
  '2026-01-18T10:30:00+08:00',
  options: const EasyParseOptions(
    mode: EasyParseMode.compatible,
    offsetResolution: OffsetResolution.fixed,
  ),
);
```

## Common tasks

### Create values with an explicit timezone

```dart
final tokyoNow = EasyDateTime.now(location: TimeZones.tokyo);
final meeting = EasyDateTime(2026, 5, 3, 9, 30, location: TimeZones.london);
```

### Run DST-safe calendar arithmetic

```dart
final ny = TimeZones.newYork;
final beforeDst = EasyDateTime(2025, 3, 9, 0, 0, location: ny);

final wallClock = beforeDst.addCalendarDays(1);       // 2025-03-10 00:00
final physical = beforeDst.add(const Duration(days: 1)); // 2025-03-10 01:00
```

### Format output

```dart
final formatted = EasyDateTime.now(location: TimeZones.tokyo)
    .format('yyyy-MM-dd HH:mm:ss xxxxx');
```

## DateTime API mapping

| Existing API | easy_date_time |
|---|---|
| `DateTime.now()` | `EasyDateTime.now()` |
| `DateTime.utc(...)` | `EasyDateTime.utc(...)` |
| `DateTime.parse(String)` | `EasyDateTime.parse(String, options: ...)` |
| `DateTime.tryParse(String)` | `EasyDateTime.tryParse(String, options: ...)` |
| `DateTime.fromMillisecondsSinceEpoch(ms)` | `EasyDateTime.fromMillisecondsSinceEpoch(ms)` |
| `DateTime.toUtc()` | `EasyDateTime.toUtc()` |
| `DateTime.toLocal()` | `EasyDateTime.toLocal()` |
| No IANA location model | `inLocation(TimeZones.xxx)` |
| No global location override | `setDefaultLocation(...)` / `clearDefaultLocation()` |

## Migration notes for v0.12

- `strict: false` maps to `EasyParseMode.compatible`
- `strict: true` maps to `EasyParseMode.isoStrict`
- `strict` is deprecated in `parse()` and `tryParse()`

```dart
// Before
EasyDateTime.parse(input, strict: true);

// After
EasyDateTime.parse(
  input,
  options: const EasyParseOptions(mode: EasyParseMode.isoStrict),
);
```

For full migration details, see [docs/migration/v0_12_migration_guide.md](docs/migration/v0_12_migration_guide.md).

## Support

- Issues: https://github.com/MasterHiei/easy_date_time/issues
- Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md)
