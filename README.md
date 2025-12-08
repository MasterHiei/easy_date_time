# easy_date_time

**Timezone-aware DateTime for Dart**

A drop-in DateTime alternative with full IANA timezone support. Designed to parse and maintain timezone information accurately without implicit UTC conversions.

[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)

**[中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md)** | **[日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)**

---

## Why easy_date_time?

Dart's built-in `DateTime` and existing libraries often face limitations when handling complex timezone scenarios:

| Existing Solution | Strengths | Limitations | EasyDateTime Approach |
|-------------------|-----------|-------------|-----------------------|
| **DateTime** (Built-in) | Standard, zero dependencies | Auto-converts offsets to UTC/Local, **loses timezone context** | **Preserves Semantics**: Retains the exact parsed time and offset. |
| **timezone** | Full IANA support | Complex API, requires looking up zone strings | **Usability**: providing constants for common timezones. |
| **intl** | Excellent for formatting | Primarily for display, lacks calculation features | **Separation of Concerns**: specialized in calculation, works with intl. |
| **flutter_native_timezone** | Access system timezone | Fetch only, no calculation capabilities | **Comprehensive**: A complete solution for parsing, calculating, and converting. |

**Comparison:**

```dart
// DateTime: Parses offset but converts to UTC, changing the hour value
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2 (Context lost)

// EasyDateTime: Retains the parsed time value
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10 (As expected)
```

---

## Key Features

* 🌍 **Full IANA Timezone Support**
  Support for all IANA timezones (e.g., `Asia/Shanghai`, `America/New_York`) with a simple API.

* 🕒 **Preserves Parsed Values**
  No implicit conversion to UTC. The time you parse is the time stored.

* ➕ **Intuitive Arithmetic**
  Supports natural arithmetic extensions like `now + 1.days` or `2.hours`.

* 🔄 **Explicit Conversion**
  Timezone conversion only happens when explicitly requested via `.inLocation()` or `.toUtc()`.

* 🧱 **Safe Date Calculation**
  Handles month/year overflows gracefully (e.g., Jan 31 + 1 month -> Feb 28) with `copyWithClamped`.

---

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  easy_date_time: ^0.2.0
```

**Note**: You **must** initialize the timezone database before using the library to ensure accuracy:

```dart
void main() {
  initializeTimeZone();  // Required

  // Optional: Set a global default location
  setDefaultLocation(TimeZones.shanghai);

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

Pre-defined constants are available for common timezones:

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

Setting a default location allows `EasyDateTime.now()` to use that timezone globally:

```dart
setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now();  // Returns time in Asia/Shanghai
```

---

## Preserving Time Semantics

Even when parsing strings with offsets, `EasyDateTime` preserves both the literal time and the timezone location:

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10
print(dt.locationName);  // Asia/Shanghai
```

To convert timezones, use explicit methods:

```dart
final ny = dt.inLocation(TimeZones.newYork);
final utc = dt.toUtc();
```

---

## Timezone Conversion

Comparing the same instant across different timezones:

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final newYork = tokyo.inLocation(TimeZones.newYork);

print(tokyo.isAtSameMomentAs(newYork));  // true: Represents the same absolute instant
```

---

## Date Arithmetic

```dart
final now = EasyDateTime.now();
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
```

### Handling Month Overflow

`EasyDateTime` provides safe handling for month overflows:

```dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // March 3rd (Standard overflow behavior)
jan31.copyWithClamped(month: 2); // Feb 28 (Clamped to the last day of the month)
```

---

## Extension Handling

This package includes extensions on `int` (e.g., `1.days`). If this conflicts with other packages, specialized imports can hide the extension:

```dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
```

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

* `==` calculates equality based on the **absolute instant**, ignoring timezone differences.
* Only valid IANA timezone offsets are supported; non-standard offsets will throw an error.
* `initializeTimeZone()` must be called before use.

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
