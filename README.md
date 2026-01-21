# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

[中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md) | [日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)

A drop-in replacement for Dart's `DateTime` with IANA timezone support. It preserves the original time values when parsing and simplifies timezone handling.

~~~dart
// DateTime converts to UTC across timezones, often changing the hour
DateTime.parse('2026-01-18T10:30:00+08:00').hour   // 2

// EasyDateTime keeps the original hour and timezone context
EasyDateTime.parse('2026-01-18T10:30:00+08:00').hour  // 10
~~~

## Installation

### Dependency

Add the package to your `pubspec.yaml`:

~~~yaml
dependencies:
  easy_date_time: ^0.11.0
~~~

### Initialization

You **must** initialize the timezone database before using the library:

~~~dart
void main() {
  // Call this once before any usage
  EasyDateTime.initializeTimeZone();
  runApp(MyApp());
}
~~~

## Usage

Construct and parse with timezone awareness:

~~~dart
// Use a predefined location
final now = EasyDateTime.now(location: TimeZones.tokyo);

// Parse a string while preserving its offset and location
final parsed = EasyDateTime.parse('2026-01-18T10:30:00+08:00');

print(parsed.hour);         // 10
print(parsed.locationName); // Asia/Shanghai
~~~

Arithmetic with `Duration` extensions:

~~~dart
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
~~~

Format with pattern strings:

~~~dart
// 2026-01-18 10:30
print(dt.format('yyyy-MM-dd HH:mm'));
~~~

## Features

### Timezones

There are three ways to specify a timezone (Location):

~~~dart
// 1. Using TimeZones constants (Recommended)
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);

// 2. Using IANA timezone naming
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));

// 3. Setting a global default
EasyDateTime.setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now();  // Uses Asia/Shanghai by default
~~~

Convert between timezones:

~~~dart
final newYork = tokyo.inLocation(TimeZones.newYork);
tokyo.isAtSameMomentAs(newYork);  // true — represents the same instant
~~~

### Arithmetic

Syntax using extensions:

~~~dart
now + 1.days
now - 2.hours
now + 30.minutes + 15.seconds
~~~

**DST-Safe Calendar Arithmetic**

When adding time across Daylight Saving Time boundaries, `addCalendarDays` preserves the "wall time" (the time on the clock), whereas standard addition respects physical time.

~~~dart
// DST transition day in New York (March 9, 2025: clocks jump forward)
final dt = EasyDateTime(2025, 3, 9, 0, 0, location: newYork);

dt.addCalendarDays(1);      // 2025-03-10 00:00 — Same clock time
dt.add(Duration(days: 1));  // 2025-03-10 01:00 — 24 physical hours later
~~~

Convenience getters:

~~~dart
dt.tomorrow    // The next calendar day
dt.yesterday   // The previous calendar day
dt.dateOnly    // Resets time components to 00:00:00
~~~

**Month Overflow Handling**

Handle cases where a month change results in an invalid date (e.g., changing Jan 31st to February):

~~~dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // Mar 3 (Standard overflow behavior)
jan31.copyWithClamped(month: 2); // Feb 28 (Clamped to the last valid day)
~~~

**Time Unit Boundaries**

Calculate start and end points:

~~~dart
dt.startOf(DateTimeUnit.day);    // 00:00:00.000
dt.startOf(DateTimeUnit.week);   // Monday 00:00:00 (ISO 8601)
dt.startOf(DateTimeUnit.month);  // 1st of month 00:00:00
dt.endOf(DateTimeUnit.month);    // Last day of month 23:59:59.999
~~~

### Properties

Date components:

- `dayOfYear` — Day number (1-366)
- `weekOfYear` — ISO 8601 week number (1-53)
- `quarter` — Quarter of the year (1-4)
- `daysInMonth` — Total days in the current month (28-31)
- `isLeapYear` — true if leap year

Status checkers:

- `isToday`, `isTomorrow`, `isYesterday`
- `isThisWeek`, `isThisMonth`, `isThisYear`
- `isWeekend`, `isWeekday`
- `isPast`, `isFuture`

Timezone info:

- `isDst` — true if currently in Daylight Saving Time
- `locationName` — IANA timezone identifier

### Formatting

Format dates using patterns:

~~~dart
dt.format('yyyy-MM-dd');    // 2026-01-18
dt.format('HH:mm:ss');      // 14:30:45
dt.format('hh:mm a');       // 02:30 PM
~~~

Or use predefined constants:

~~~dart
dt.format(DateTimeFormats.isoDate);      // 2026-01-18
dt.format(DateTimeFormats.isoDateTime);  // 2026-01-18T14:30:45
dt.format(DateTimeFormats.rfc2822);      // Sun, 18 Jan 2026 14:30:45 +0800
~~~

> **Performance**: In loops or high-throughput scenarios, it is recommended to reuse `EasyDateTimeFormatter` instances.

~~~dart
static final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');
formatter.format(dt);
~~~

**Pattern Tokens:**

| Token | Description | Example |
|-------|-------------|---------|
| `yyyy` | 4-digit year | 2025 |
| `MM` / `M` | Month | 01 / 1 |
| `dd` / `d` | Day | 07 / 7 |
| `HH` / `H` | Hour (24h) | 09 / 9 |
| `hh` / `h` | Hour (12h) | 02 / 2 |
| `mm` / `m` | Minute | 05 / 5 |
| `ss` / `s` | Second | 05 / 5 |
| `SSS` | Millisecond | 123 |
| `a` | AM / PM | AM / PM |
| `EEE` | Day of week | Mon |
| `MMM` | Month name | Dec |
| `xxxxx` | Offset | +08:00 |
| `X` | ISO Offset | Z / +0800 |

### Integration with `intl`

`EasyDateTime` implements the `DateTime` interface, making it compatible with `package:intl` without modification:

~~~dart
import 'package:intl/intl.dart';

DateFormat.yMMMMd('ja').format(dt);  // 2025年12月7日
DateFormat.yMMMMd('en').format(dt);  // December 7, 2025
~~~

### JSON Serialization

Custom converters are provided for `json_serializable` and `freezed`:

~~~dart
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}
~~~

Usage with `freezed`:

~~~dart
@freezed
class Event with _$Event {
  const factory Event({
    @EasyDateTimeConverter() required EasyDateTime startTime,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
~~~

## Important Notes

**Equality (`==`)**
Equality intentionally follows Dart's `DateTime` semantics.
- `==` compares absolute time value AND timezone/location.
- `isAtSameMomentAs` compares only the absolute time value (instant).

~~~dart
final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
final local = EasyDateTime.parse('2026-01-18T08:00:00+08:00');

utc == local;                  // false — different Location
utc.isAtSameMomentAs(local);   // true — same instant in time
~~~

> **Warning:** Do not mix `EasyDateTime` and `DateTime` in the same `Set` or `Map` key, as their `hashCode` implementations differ.

**Auto-Correction vs. Strict Mode**

The `strict` parameter is available **only** for `parse()` and `tryParse()` methods, not for constructors.

**Constructor behavior** (always overflows):

~~~dart
// Constructors always overflow - no strict mode available
EasyDateTime(2025, 2, 30);     // Becomes 2025-03-02
EasyDateTime.utc(2025, 4, 31); // Becomes 2025-05-01
~~~

**Parsing methods** support strict validation via the `strict` parameter:

~~~dart
// Default: invalid dates overflow
EasyDateTime.parse('2025-02-30');  // 2025-03-02

// Strict mode: throws FormatException for invalid dates
EasyDateTime.parse('2025-02-30', strict: true);  // ❌ FormatException

// Strict mode with tryParse: returns null for invalid dates
EasyDateTime.tryParse('2025-02-30', strict: true);  // null
~~~

> **Note**: Strict mode validates calendar correctness (e.g., no Feb 30, no month 13) and ISO 8601 format compliance. Use `tryParse()` with `strict: true` for safe validation of user input.


**Safe Parsing**
Always use `tryParse` for handling potentially malformed user input:

~~~dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  // Handle invalid format
}
~~~

**Extension Conflicts**
If `1.days` conflicts with another package (like `time`), hide the extension:

~~~dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
~~~

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

BSD 2-Clause
