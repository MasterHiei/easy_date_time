# easy_date_time

**Timezone-aware DateTime for Dart**

A drop-in replacement for DateTime with full IANA timezone support, intuitive arithmetic, and flexible formatting. **Immutable**, accurate, and developer-friendly.

[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)

**[中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md)** | **[日本語](https://github.com/MasterHiei/easy_date_time/blob/main/README_ja.md)**

---

## Why easy_date_time?

Dart's built-in `DateTime` and existing libraries often face limitations when handling complex timezone scenarios:

| Existing Solution | Strengths | Limitations | EasyDateTime Approach |
|-------------------|-----------|-------------|-----------------------|
| **DateTime** (Built-in) | Standard, zero dependencies | Auto-converts offsets to UTC/Local, **loses timezone context** | **Semantics Preserved**: Losslessly retains parsed time and offset. |
| **timezone** | Full IANA support | Complex API, manual zone lookup required | **Developer Friendly**: Type-safe constants (e.g., `TimeZones.tokyo`). |
| **intl** | Excellent for formatting | Display-focused, lacks calculation APIs | **Calculation Logic**: Works alongside `intl` for complex math sequences. |
| **flutter_native_timezone** | Access system timezone | Fetch-only, no calculation capabilities | **Complete Solution**: Unified parsing, calculation, and conversion. |

**Comparison:**

```dart
// ❌ Native DateTime: Implicitly converts to UTC/Local, losing the original offset context.
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2 (Changed to UTC hour)

// ✅ EasyDateTime: Preserves the exact parsed hour and offset.
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10 (Preserved)
```

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
  easy_date_time: ^0.3.5
```

**Note**: You **must** initialize the timezone database before using the library.

```dart
void main() {
  EasyDateTime.initializeTimeZone();  // Required

  // Optional: Set a global default location
  EasyDateTime.setDefaultLocation(TimeZones.shanghai);

  runApp(MyApp());
}
```

> [!NOTE]
> Global functions like `initializeTimeZone()` and `setDefaultLocation()` are **deprecated**.
> Use the static methods `EasyDateTime.initializeTimeZone()` and `EasyDateTime.setDefaultLocation()` instead.

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
final effective = EasyDateTime.effectiveDefaultLocation;  // or effectiveDefaultLocation
```

---

## Preserving Time Semantics

`EasyDateTime` preserves both the literal time and the timezone location, even when parsing strings with offsets:

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10
print(dt.locationName);  // Asia/Shanghai
```

Use explicit methods to convert timezones:

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

jan31.copyWith(month: 2);        // ⚠️ Mar 3rd (Standard overflow)
jan31.copyWithClamped(month: 2); // ✅ Feb 28 (Clamped to last valid day)
```

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
* `EasyDateTime.initializeTimeZone()` must be called before use.

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
