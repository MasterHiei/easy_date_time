# easy_date_time

**Timezone-aware DateTime for Dart**

A straightforward solution for timezone handling in Dart, built on the established `timezone` package.

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)

**[中文文档](README_zh.md)** | **[日本語ドキュメント](README_ja.md)**

---

## Why easy_date_time?

- 🌍 **True Timezone Support**: Handle any IANA timezone (e.g., `Asia/Shanghai`, `America/New_York`), not just UTC/Local.
- 🕒 **Preserves Time**: Parsing `"10:00+08:00"` gives you `10:00`, not `02:00` UTC.
- 🛠️ **Developer Friendly**: Intuitive operators (`now + 1.days`) and standard JSON serialization.

## Quick Start

```yaml
dependencies:
  easy_date_time: ^0.1.0
```

```dart
import 'package:easy_date_time/easy_date_time.dart';

void main() {
  // 1. Initialize logic (Drivers)
  initializeTimeZone();

  // 2. Configure defaults (Policy, optional)
  setDefaultLocation(TimeZones.shanghai);

  final now = EasyDateTime.now();  // Uses default (Shanghai)
  print(now);
}
```

---

## Specifying Timezone

### Method 1: Use `TimeZones` shortcuts (recommended)

```dart
// Common timezones available as properties
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
final newYork = EasyDateTime.now(location: TimeZones.newYork);

// Available: tokyo, shanghai, beijing, hongKong, singapore,
// newYork, losAngeles, chicago, london, paris, berlin,
// sydney, auckland, moscow, dubai, mumbai, and more...
```

### Method 2: Use `getLocation()` for any IANA timezone

```dart
// For timezones not in TimeZones
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
final denver = EasyDateTime.now(location: getLocation('America/Denver'));

// Full list: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
```

### Method 3: Set global default

```dart
// Set once, applies to all subsequent operations
setDefaultLocation(TimeZones.shanghai);

final now = EasyDateTime.now();  // Shanghai time
final dt = EasyDateTime(2025, 12, 25, 10, 30);  // Also Shanghai time
```

---

## Parsing Timestamps

**Time values are preserved** - no automatic conversion:

```dart
// Parse API response with timezone offset
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
print(dt.hour);  // 10 (not 2!)
print(dt.locationName);  // Asia/Shanghai

// Parse UTC time
final utc = EasyDateTime.parse('2025-12-07T10:30:00Z');
print(utc.hour);  // 10
print(utc.locationName);  // UTC

// Explicit conversion (only when you ask for it)
final inNY = EasyDateTime.parse(
  '2025-12-07T10:30:00Z',
  location: TimeZones.newYork,
);
print(inNY.hour);  // 5 (10 UTC → 5 NY)
```

---

## Timezone Conversion

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);

// Convert to another timezone
final newYork = tokyo.inLocation(TimeZones.newYork);

// Convert to UTC
final utc = tokyo.inUtc();

// Same moment, different display
print(tokyo.isAtSameMoment(newYork));  // true
```

---

## Date Arithmetic

```dart
final now = EasyDateTime.now();

// Add/subtract with operators
final tomorrow = now + 1.days;
final lastWeek = now - 1.weeks;
final later = now + 2.hours + 30.minutes;

// Compare
if (tomorrow > now) {
  print('Future');
}

// Calculate difference
final duration = tomorrow.difference(now);
```

---

## JSON Serialization

Compatible with json_serializable and freezed:

```dart
// Manual serialization
final json = dt.toJson();  // "2025-12-25T10:30:00.000+0900"
final restored = EasyDateTime.fromJson(json);

// With freezed/json_serializable - define a custom converter:
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromJson(json);

  @override
  String toJson(EasyDateTime object) => object.toJson();
}

// Use in your models:
@freezed
class Event with _$Event {
  const factory Event({
    @EasyDateTimeConverter() required EasyDateTime startTime,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
```

See [example/lib/integrations/](example/lib/integrations/) for complete examples.



## API Reference

### Constructors

| Constructor | Description |
|-------------|-------------|
| `EasyDateTime(year, month, day, ...)` | Create from components |
| `EasyDateTime.now()` | Current time |
| `EasyDateTime.utc(...)` | Create in UTC |
| `EasyDateTime.parse(string)` | Parse ISO 8601 |
| `EasyDateTime.fromJson(string)` | From JSON |

### Timezone Methods

| Method | Description |
|--------|-------------|
| `inLocation(location)` | Convert to timezone |
| `inUtc()` | Convert to UTC |
| `inLocalTime()` | Convert to system local |

### Date Utilities

| Property/Method | Description |
|-----------------|-------------|
| `isToday` | Is today? |
| `isTomorrow` | Is tomorrow? |
| `isYesterday` | Is yesterday? |
| `startOfDay` | 00:00:00 |
| `endOfDay` | 23:59:59 |
| `startOfMonth` | First day of month |
| `endOfMonth` | Last day of month |

---

## License

BSD 2-Clause License
