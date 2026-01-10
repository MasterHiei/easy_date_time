# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

[中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md) | [日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)

A drop-in DateTime replacement with IANA timezone support. Preserves original time values when parsing.

~~~dart
// DateTime converts to UTC, changing the hour
DateTime.parse('2025-12-07T10:30:00+08:00').hour   // 2

// EasyDateTime keeps the original hour
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // 10
~~~

## Install

### Dependency

Add to your `pubspec.yaml`:

~~~yaml
dependencies:
  easy_date_time: ^0.9.1
~~~

### Initialization

Initialize the timezone database before use:

~~~dart
void main() {
  EasyDateTime.initializeTimeZone();
  runApp(MyApp());
}
~~~

## Usage

Create and parse datetime with timezone:

~~~dart
final now = EasyDateTime.now(location: TimeZones.tokyo);
final parsed = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(parsed.hour);         // 10
print(parsed.locationName); // Asia/Shanghai
~~~

Use Duration extensions for arithmetic:

~~~dart
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
~~~

Format with pattern strings:

~~~dart
// 2025-12-07 10:30
print(dt.format('yyyy-MM-dd HH:mm'));
~~~

## Features

### Timezones

Three ways to specify timezone:

~~~dart
// 1. TimeZones constants
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);

// 2. IANA timezone names
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));

// 3. Global default
EasyDateTime.setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now();  // uses Asia/Shanghai
~~~

Convert between timezones:

~~~dart
final newYork = tokyo.inLocation(TimeZones.newYork);
tokyo.isAtSameMomentAs(newYork);  // true — same instant
~~~

### Arithmetic

Duration extensions provide natural syntax:

~~~dart
now + 1.days
now - 2.hours
now + 30.minutes + 15.seconds
~~~

Calendar arithmetic preserves wall time during DST changes:

~~~dart
// DST transition day in New York (March 9, 2025)
final dt = EasyDateTime(2025, 3, 9, 0, 0, location: newYork);

dt.addCalendarDays(1);      // 2025-03-10 00:00 — same wall time
dt.add(Duration(days: 1));  // 2025-03-10 01:00 — 24 hours later
~~~

Related getters:

~~~dart
dt.tomorrow    // next calendar day
dt.yesterday   // previous calendar day
dt.dateOnly    // time set to 00:00:00
~~~

Safe month overflow handling:

~~~dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // Mar 3 (overflow)
jan31.copyWithClamped(month: 2); // Feb 28 (clamped to valid day)
~~~

Get boundaries of time units:

~~~dart
dt.startOf(DateTimeUnit.day);    // 00:00:00
dt.startOf(DateTimeUnit.week);   // Monday 00:00:00 (ISO 8601)
dt.startOf(DateTimeUnit.month);  // 1st 00:00:00
dt.endOf(DateTimeUnit.month);    // last day 23:59:59.999999
~~~

### Properties

Date calculations:

- `dayOfYear` — day number within year (1-366)
- `weekOfYear` — ISO 8601 week number (1-53)
- `quarter` — quarter of year (1-4)
- `daysInMonth` — days in current month (28-31)
- `isLeapYear` — whether year is a leap year

Day checks:

- `isToday`, `isTomorrow`, `isYesterday`
- `isThisWeek`, `isThisMonth`, `isThisYear`
- `isWeekend`, `isWeekday`
- `isPast`, `isFuture`

Timezone:

- `isDst` — whether daylight saving time is active
- `locationName` — IANA timezone name

### Formatting

Use `format()` with pattern strings:

~~~dart
dt.format('yyyy-MM-dd');    // 2025-12-07
dt.format('HH:mm:ss');      // 14:30:45
dt.format('hh:mm a');       // 02:30 PM
~~~

Predefined format constants:

~~~dart
dt.format(DateTimeFormats.isoDate);      // 2025-12-07
dt.format(DateTimeFormats.isoDateTime);  // 2025-12-07T14:30:45
dt.format(DateTimeFormats.rfc2822);      // Mon, 07 Dec 2025 14:30:45 +0800
~~~

For performance in loops, pre-compile the pattern:

~~~dart
static final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');
formatter.format(dt);
~~~

Pattern tokens:

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

### intl

`EasyDateTime` implements `DateTime` and works directly with the `intl` package:

~~~dart
import 'package:intl/intl.dart';

DateFormat.yMMMMd('ja').format(dt);  // 2025年12月7日
DateFormat.yMMMMd('en').format(dt);  // December 7, 2025
~~~

### JSON

Use a custom converter with `json_serializable` or `freezed`:

~~~dart
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}
~~~

With freezed:

~~~dart
@freezed
class Event with _$Event {
  const factory Event({
    @EasyDateTimeConverter() required EasyDateTime startTime,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
~~~

## Notes

**Equality** follows Dart's `DateTime` semantics:

~~~dart
final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
final local = EasyDateTime.parse('2025-01-01T08:00:00+08:00');

utc == local;                  // false — different timezone type
utc.isAtSameMomentAs(local);   // true — same instant
~~~

**Avoid** mixing `EasyDateTime` and `DateTime` in the same `Set` or `Map`. They have different `hashCode` implementations.

**Invalid dates** automatically roll over:

~~~dart
EasyDateTime(2025, 2, 30);  // 2025-03-02
~~~

**Safe parsing** for user input:

~~~dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  // invalid format
}
~~~

**Extension conflicts** — if `1.days` conflicts with another package:

~~~dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
~~~

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

BSD 2-Clause
