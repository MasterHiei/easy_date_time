# easy_date_time

**Timezone-aware DateTime for Dart**

A drop-in replacement for DateTime with full IANA timezone support, intuitive arithmetic, and flexible formatting. **Immutable**, accurate, and developer-friendly.

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)


**[中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md)** | **[日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)**

---

## Why easy_date_time?

Dart's `DateTime` only supports UTC and local time. This package adds full IANA timezone support as a true drop-in replacement.

### Comparison with Other DateTime Packages

| Feature | `DateTime` | `timezone` | `easy_date_time` |
|---------|:----------:|:----------:|:----------------:|
| **IANA Timezones** | ❌ | ✅ | ✅ |
| **Immutability** | ✅ | ✅ | ✅ |
| **API Interface** | Native | `extends DateTime` | `implements DateTime` |
| **Location Lookup** | N/A | Manual (`getLocation`) | Constants / Auto-cache |

### API Design Comparison

**`timezone` package:**
```dart
import 'package:timezone/timezone.dart' as tz;
// Requires explicit location lookup
final detroit = tz.getLocation('America/Detroit');
final now = tz.TZDateTime.now(detroit);
```

**`easy_date_time`:**
```dart
// Uses static constants or cached lookups
final now = EasyDateTime.now(location: TimeZones.detroit);
```

### DateTime vs EasyDateTime

```dart
// DateTime: offset → UTC (hour changes)
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2

// EasyDateTime: hour preserved
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10
```

| Feature | DateTime | EasyDateTime |
|---|----------|--------------|
| **Timezone Support** | UTC / System Local | IANA Database |
| **Parsing Behavior** | **Normalization** (converts to UTC) | **Preservation** (keeps offset/hour) |
| **Type Relation** | Base Class | `implements DateTime` |
| **Mixed Use** | N/A | ⚠️ `hashCode` differs |

---

## Key Features

### 🌍 Full IANA Timezone Support
Use standard IANA constants or custom strings.
```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
```

### 🕒 Lossless Parsing
No implicit UTC conversion. Retains the exact parsed values.
```dart
EasyDateTime.parse('2025-12-07T10:00+08:00').hour // -> 10
```

### ➕ Intuitive Arithmetic
Natural syntax for date calculations.
```dart
final later = now + 2.hours + 30.minutes;
```

### 🧱 Safe Date Calculation
Handles month overflow intelligently.
```dart
jan31.copyWithClamped(month: 2); // -> Feb 28
```

### 📝 Flexible Formatting
Performance-optimized formatting.
```dart
dt.format('yyyy-MM-dd'); // -> 2025-12-07
```

---

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  easy_date_time: ^0.8.0
```

**Note**: You **must** initialize the timezone database before using this package.

```dart
void main() {
  EasyDateTime.initializeTimeZone();  // Required

  // Optional: Set a global default location
  EasyDateTime.setDefaultLocation(TimeZones.shanghai);

  runApp(MyApp());
}
```

---

## Quick Start

```dart
final now = EasyDateTime.now();  // Uses default or local timezone
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final parsed = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(parsed.hour);  // 10
```

---

## Working with Timezones

### 1. Common Timezones (Recommended)

Use pre-defined constants for common timezones:

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
```

### 2. Custom IANA Timezones

You can also use standard IANA strings:

```dart
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
```

### 3. Global Default Timezone

Setting a default location allows `EasyDateTime.now()` to use that timezone globally.

```dart
EasyDateTime.setDefaultLocation(TimeZones.shanghai);

final now = EasyDateTime.now();  // Returns time in Asia/Shanghai
```

**Managing the default timezone:**

```dart
// Get the current default timezone
final current = EasyDateTime.getDefaultLocation();

// Clear the default (reverts to system local timezone)
EasyDateTime.clearDefaultLocation();

// Get the effective default location (user-set or system local)
final effective = EasyDateTime.effectiveDefaultLocation;
```

---

## Timezone Handling

`EasyDateTime` preserves both the literal time and the timezone location when parsing:

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10 (preserved, not converted to UTC)
print(dt.locationName);  // Asia/Shanghai
```

### Converting Between Timezones

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final newYork = tokyo.inLocation(TimeZones.newYork);
final utc = tokyo.toUtc();

tokyo.isAtSameMomentAs(newYork);  // true: Same absolute instant
```

---

## Date Arithmetic

```dart
final now = EasyDateTime.now();
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
```

### Calendar Day Arithmetic (DST-safe)

For day-based operations that should preserve time of day (important for DST transitions):

```dart
final dt = EasyDateTime(2025, 3, 9, 0, 0, location: newYork); // DST transition day

dt.addCalendarDays(1);       // 2025-03-10 00:00 ✓ (same time)
dt.add(Duration(days: 1));   // 2025-03-10 01:00   (24h later, time shifted)
```

The `tomorrow` and `yesterday` getters also use calendar day semantics:

```dart
dt.tomorrow;   // Equivalent to addCalendarDays(1)
dt.yesterday;  // Equivalent to subtractCalendarDays(1)
```

### Handling Month Overflow

`EasyDateTime` provides safe handling for month overflows:

```dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // ⚠️ Mar 3rd (Standard overflow)
jan31.copyWithClamped(month: 2); // ✅ Feb 28 (Clamped to last valid day)
```

### Start and End of Time Units

Truncate or extend a datetime to the boundary of a time unit:

```dart
final dt = EasyDateTime(2025, 6, 18, 14, 30, 45); // Wednesday

dt.startOf(DateTimeUnit.day);   // 2025-06-18 00:00:00
dt.startOf(DateTimeUnit.week);  // 2025-06-16 00:00:00 (Monday)
dt.startOf(DateTimeUnit.month); // 2025-06-01 00:00:00

dt.endOf(DateTimeUnit.day);     // 2025-06-18 23:59:59.999999
dt.endOf(DateTimeUnit.week);    // 2025-06-22 23:59:59.999999 (Sunday)
dt.endOf(DateTimeUnit.month);   // 2025-06-30 23:59:59.999999
```

> Week boundaries follow ISO 8601 (Monday = first day of week).

### Date Properties

Convenient properties for common date calculations:

~~~dart
final dt = EasyDateTime(2024, 6, 15);

// Year-based calculations
dt.dayOfYear;    // 167 (day 167 of the year)
dt.weekOfYear;   // 24 (ISO 8601 week number)
dt.quarter;      // 2 (Q2: Apr-Jun)
dt.isLeapYear;   // true

// Month info
dt.daysInMonth;  // 30 (June has 30 days)

// Weekend/weekday checks
final saturday = EasyDateTime(2025, 1, 4);
saturday.isWeekend;  // true
saturday.isWeekday;  // false

// Time-based queries
final past = EasyDateTime(2020, 1, 1);
past.isPast;       // true
past.isFuture;     // false

final now = EasyDateTime.now();
now.isThisWeek;    // true
now.isThisMonth;   // true
now.isThisYear;    // true

// DST detection
final nyJuly = EasyDateTime(2025, 7, 15, location: TimeZones.newYork);
nyJuly.isDst;      // true (EDT active)
~~~

| Property | Description | Example |
|----------|-------------|---------|
| `dayOfYear` | Day of year (1-366) | 167 |
| `weekOfYear` | ISO 8601 week number (1-53) | 24 |
| `quarter` | Quarter of year (1-4) | 1, 2, 3, 4 |
| `daysInMonth` | Days in current month | 28, 29, 30, 31 |
| `isLeapYear` | Whether year is a leap year | true/false |
| `isWeekend` | Saturday or Sunday | true/false |
| `isWeekday` | Monday through Friday | true/false |
| `isPast` | Before current time | true/false |
| `isFuture` | After current time | true/false |
| `isThisWeek` | Within current week | true/false |
| `isThisMonth` | Within current month | true/false |
| `isThisYear` | Within current year | true/false |
| `isDst` | Daylight saving time active | true/false |

---

## Date Formatting

Use the `format()` method with pattern tokens for flexible date/time formatting:

```dart
final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);

dt.format('yyyy-MM-dd');           // '2025-12-01'
dt.format('yyyy/MM/dd HH:mm:ss');  // '2025/12/01 14:30:45'
dt.format('MM/dd/yyyy');           // '12/01/2025'
dt.format('hh:mm a');              // '02:30 PM'
```

> [!TIP]
> **Performance Optimization**: For hot paths (e.g., loops), use `EasyDateTimeFormatter` to pre-compile patterns.
> ```dart
> // Compiled once, reused multiple times
> static final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');
> String result = formatter.format(date);
> ```

### Predefined Formats

Use `DateTimeFormats` for common patterns:

```dart
dt.format(DateTimeFormats.isoDate);      // '2025-12-01'
dt.format(DateTimeFormats.isoTime);      // '14:30:45'
dt.format(DateTimeFormats.isoDateTime);  // '2025-12-01T14:30:45'
dt.format(DateTimeFormats.time12Hour);   // '02:30 PM'
dt.format(DateTimeFormats.time24Hour);   // '14:30'
dt.format(DateTimeFormats.rfc2822);      // 'Mon, 01 Dec 2025 14:30:45 +0800'
```

### Pattern Tokens

| Token | Description | Example |
|-------|-------------|---------|
| `yyyy` | 4-digit year | 2025 |
| `MM`/`M` | Month (padded/unpadded) | 01, 1 |
| `MMM` | Month abbreviation | Jan, Dec |
| `dd`/`d` | Day (padded/unpadded) | 01, 1 |
| `EEE` | Day-of-week abbreviation | Mon, Sun |
| `HH`/`H` | 24-hour (padded/unpadded) | 09, 9 |
| `hh`/`h` | 12-hour (padded/unpadded) | 02, 2 |
| `mm`/`m` | Minutes (padded/unpadded) | 05, 5 |
| `ss`/`s` | Seconds (padded/unpadded) | 05, 5 |
| `SSS` | Milliseconds | 123 |
| `a` | AM/PM marker | AM, PM |
| `xxxxx` | Timezone offset with colon | +08:00, -05:00 |
| `xxxx` | Timezone offset | +0800, -0500 |
| `xx` | Short timezone offset | +08, -05 |
| `X` | ISO timezone (Z or +0800) | Z, +0800 |

---

## Extension Handling

This package adds extensions on `int` (e.g., `1.days`). If this conflicts with other packages, hide the extension via specialized imports:

```dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
```

---

## Integration with intl

For locale-aware formatting (e.g., "January" → "一月"), use `EasyDateTime` with the `intl` package:

```dart
import 'package:intl/intl.dart';
import 'package:easy_date_time/easy_date_time.dart';

final dt = EasyDateTime.now(location: TimeZones.tokyo);

// Locale-aware formatting via intl
DateFormat.yMMMMd('ja').format(dt);  // '2025年12月20日'
DateFormat.yMMMMd('en').format(dt);  // 'December 20, 2025'
```

> **Note**: `EasyDateTime` implements `DateTime`, so it works directly with `DateFormat.format()`.

---

## JSON & Serialization

Compatible with `json_serializable` and `freezed` via a custom converter:

```dart
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}
```

---

## Important Notes

### Equality Comparison

`EasyDateTime` follows Dart's `DateTime` semantics for equality:

```dart
final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
final local = EasyDateTime.parse('2025-01-01T08:00:00+08:00');

// Same moment, different timezone type (UTC vs non-UTC)
utc == local;                  // false
utc.isAtSameMomentAs(local);   // true
```

| Method | Compares | Use Case |
|--------|----------|----------|
| `==` | Moment + timezone type (UTC/non-UTC) | Exact equality |
| `isAtSameMomentAs()` | Absolute instant only | Cross-timezone comparison |
| `isBefore()` / `isAfter()` | Chronological order | Sorting, range checks |

> [!WARNING]
> **Avoid mixing `EasyDateTime` and `DateTime`** in the same `Set` or `Map`.
> While `==` works across types, `hashCode` implementations differ.

### Other Notes

* Only valid IANA timezone offsets are supported; non-standard offsets will throw an error.
* `EasyDateTime.initializeTimeZone()` must be called before use.

### DateTime Behavior

EasyDateTime inherits certain behaviors from Dart's `DateTime`:

**Invalid Date Rollover**: Constructing an invalid date automatically rolls over to the next valid date:
```dart
EasyDateTime(2025, 2, 30);  // → 2025-03-02 (Feb 30 doesn't exist)
EasyDateTime(2025, 2, 29);  // → 2025-03-01 (2025 is not a leap year)
```

> For DST-aware day arithmetic, see [Calendar Day Arithmetic](#calendar-day-arithmetic-dst-safe).

### Parsing User Input

Use `tryParse` for handling potentially invalid user input safely:

```dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  print('Invalid date format');
}
```

---

## Contributing

Issues and Pull Requests are welcome.
Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

BSD 2-Clause
