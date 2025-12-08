# easy_date_time

**Timezone-aware DateTime for Dart**

A drop-in DateTime alternative with full IANA timezone support. Parse times without surprise UTC conversions.

[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)

**[中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md)** | **[日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)**

---

## Why easy_date_time?

Dart's built-in `DateTime` and other solutions have limitations in real-world use:

| Package                 | Strengths             | Limitations                                 | Why easy_date_time                         |
|-------------------------|-----------------------|---------------------------------------------|--------------------------------------------|
| DateTime (built-in)     | Simple, zero deps     | Only local/UTC; offsets auto-convert to UTC | Keeps your times intact                    |
| timezone                | Precise IANA support  | Verbose API                                 | Cleaner syntax, shortcuts for common zones |
| intl                    | Great i18n/formatting | Minimal timezone support                    | Time and timezone handled separately       |
| flutter_native_timezone | Gets device timezone  | No parsing/arithmetic                       | Parse, compute, and convert in one place   |

> **In short**: Less boilerplate, fewer surprises, timezone-aware by default.

**See the difference:**

```dart
// DateTime: offset is parsed, but time gets converted to UTC
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2 😕

// EasyDateTime: what you parse is what you get
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10 ✓
```

---

## Key Features

* 🌍 **Full Timezone Support**
  All IANA timezones available (e.g., Asia/Shanghai, America/New_York)

* 🕒 **What You Parse Is What You Get**
  No automatic UTC conversion behind your back

* ➕ **Readable Arithmetic**
  `now + 1.days`, `2.hours + 30.minutes`—clean and obvious

* 🔄 **Opt-in Conversion**
  Timezone changes only when you ask (`.inLocation()`, `.toUtc()`)

* 🧱 **Safe Month/Year Changes**
  `copyWithClamped()` handles edge cases like Jan 31 → Feb

---

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  easy_date_time: ^0.2.0
```

Initialize once at app startup:

```dart
void main() {
  initializeTimeZone();  // Required

  // Optional: set default timezone
  setDefaultLocation(TimeZones.shanghai);

  runApp(MyApp());
}
```

---

## Quick Start

```dart
final now = EasyDateTime.now();  // Default or local timezone
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final parsed = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(parsed.hour);  // 10
```

---

## Using Timezones

### Common Timezones (recommended)

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
```

### Any IANA Timezone

```dart
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
```

### Global Default

```dart
setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now();  // Uses Shanghai time
```

---

## Preserving Original Time

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10
print(dt.locationName);  // Asia/Shanghai
```

Explicit conversion:

```dart
final ny = dt.inLocation(TimeZones.newYork);
final utc = dt.toUtc();
```

---

## Timezone Conversion

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final newYork = tokyo.inLocation(TimeZones.newYork);

print(tokyo.isAtSameMomentAs(newYork));  // true: same instant
```

---

## Date Arithmetic

```dart
final now = EasyDateTime.now();
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
```

### Preventing Month Overflow

```dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // March 3rd (overflow)
jan31.copyWithClamped(month: 2); // Feb 28
```

```

---

## Extension Handling

This package includes handy extensions on `int` (e.g., `1.days`). If this conflicts with other packages, you can hide it:

```dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
```

---

## JSON & Serialization

Works with `json_serializable` / `freezed` via custom converter:

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

* `==` compares whether two times represent the **same instant**
* Non-IANA timezone offsets will throw an error
* Must call `initializeTimeZone()` first

### Safe User Input Parsing

```dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  print('Invalid date format');
}
```

---

## Contributing

Issues and PRs welcome.
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

BSD 2-Clause
