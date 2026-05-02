# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

[中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md) | [日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)

A `DateTime`-compatible API with first-class IANA timezone support.

## Why easy_date_time

`DateTime.parse()` normalizes offset inputs to UTC and often changes the wall-clock hour.
`EasyDateTime.parse()` preserves the original local time context.

```dart
DateTime.parse('2026-01-18T10:30:00+08:00').hour;   // 2
EasyDateTime.parse('2026-01-18T10:30:00+08:00').hour; // 10
```

## Quick Start

### 1) Add dependency

```yaml
dependencies:
  easy_date_time: ^0.12.0
```

### 2) Initialize timezone database once

```dart
import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();
}
```

### 3) Parse and convert

```dart
final source = EasyDateTime.parse('2026-01-18T10:30:00+08:00');
final ny = source.inLocation(TimeZones.newYork);

print(source.hour);        // 10
print(source.locationName); // UTC+08:00 (fixed mode default)
print(ny.locationName);     // America/New_York
```

## Core Concepts

- `EasyDateTime` implements `DateTime`.
- Parse policy is explicit via `EasyParseOptions`.
- Parsing defaults are `mode: compatible` and `offsetResolution: fixed` when options are provided.
- Legacy no-options behavior remains available for migration-safe upgrades.

```dart
final dt = EasyDateTime.parse(
  '2026-01-18T10:30:00+08:00',
  options: const EasyParseOptions(
    mode: EasyParseMode.compatible,
    offsetResolution: OffsetResolution.fixed,
  ),
);
```

## Common Tasks

### Timezone-aware construction

```dart
final nowInTokyo = EasyDateTime.now(location: TimeZones.tokyo);
final meeting = EasyDateTime(2026, 5, 3, 9, 30, location: TimeZones.london);
```

### DST-safe calendar arithmetic

```dart
final ny = TimeZones.newYork;
final beforeDst = EasyDateTime(2025, 3, 9, 0, 0, location: ny);

final wallClock = beforeDst.addCalendarDays(1);   // 2025-03-10 00:00
final physical = beforeDst.add(const Duration(days: 1)); // 2025-03-10 01:00
```

### Formatting

```dart
final formatted = EasyDateTime.now(location: TimeZones.tokyo)
    .format('yyyy-MM-dd HH:mm:ss xxxxx');
```

## Migration Guide (v0.12)

See full guide: [docs/migration/v0_12_migration_guide.md](docs/migration/v0_12_migration_guide.md)

### `strict` to `options`

- `strict: false` -> `EasyParseOptions(mode: EasyParseMode.compatible)`
- `strict: true` -> `EasyParseOptions(mode: EasyParseMode.isoStrict)`

### Offset resolution behavior

- Legacy/default compatibility path: region inference from offset (`OffsetResolution.region`)
- New explicit path: fixed synthetic location (`OffsetResolution.fixed`, for example `UTC+08:00`)

## DateTime / timezone API Mapping

| Existing API | easy_date_time |
|---|---|
| `DateTime.now()` | `EasyDateTime.now()` |
| `DateTime.utc(...)` | `EasyDateTime.utc(...)` |
| `DateTime.parse(String)` | `EasyDateTime.parse(String, options: ...)` |
| `DateTime.tryParse(String)` | `EasyDateTime.tryParse(String, options: ...)` |
| `DateTime.fromMillisecondsSinceEpoch(ms)` | `EasyDateTime.fromMillisecondsSinceEpoch(ms)` |
| `DateTime.toUtc()` | `EasyDateTime.toUtc()` |
| `DateTime.toLocal()` | `EasyDateTime.toLocal()` |
| N/A (`DateTime` has no IANA location model) | `inLocation(TimeZones.xxx)` |
| N/A | `setDefaultLocation(...)` / `clearDefaultLocation()` |

## FAQ

### Does it work with `intl`?

Yes. `EasyDateTime` implements `DateTime`, so existing `intl` formatters can consume it directly.

### Is parsing strict by default?

No. Use `EasyParseMode.isoStrict` when strict calendar validation is required.

### Do I have to initialize timezone data?

Yes. Call `EasyDateTime.initializeTimeZone()` before using timezone-aware features.
