# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.10.0] - 2026-01-18

### Added

- Added `meta` dependency for internal API annotations.

### Changed

- **BREAKING**: Upgraded minimum SDK constraint to `3.10.0`.
- **BREAKING**: Upgraded `timezone` dependency to `>=0.11.0 <0.12.0`.
- Switched to `package:timezone/data/latest_all.dart` for comprehensive IANA support.
- Optimized `TimeZones` class with `static final` fields for improved performance.
- Upgraded `lints` dev dependency to `^6.0.0`.

### Removed

- **BREAKING**: Removed `internalInitializeTimeZone` and `internalIsTimeZoneInitialized` from public export.

## [0.9.1] - 2026-01-11

### Changed

- Updated READMEs.

## [0.9.0] - 2026-01-10

### Added

- `isDst`: Returns whether the datetime is in daylight saving time.
- `isPast`: Returns whether the datetime is before the current time.
- `isFuture`: Returns whether the datetime is after the current time.
- `isThisWeek`: Returns whether the datetime falls within the current week.
- `isThisMonth`: Returns whether the datetime falls within the current month.
- `isThisYear`: Returns whether the datetime falls within the current year.

## [0.8.0] - 2026-01-04

### Added

- `daysInMonth`: Returns the number of days in the current month.
- `isLeapYear`: Returns whether the current year is a leap year.
- `isWeekend`: Returns whether the date is Saturday or Sunday.
- `isWeekday`: Returns whether the date is Monday through Friday.
- `quarter`: Returns the quarter of the year (1-4).

## [0.7.0] - 2026-01-03

### Added

- `dayOfYear`: Returns day of year (1-366).
- `weekOfYear`: Returns ISO 8601 week number (1-53).

## [0.6.1] - 2025-12-30

### Changed

- Updated READMEs.

## [0.6.0] - 2025-12-29

### Added

- `addCalendarDays(int days)`: Adds calendar days preserving local time (DST-safe).
- `subtractCalendarDays(int days)`: Subtracts calendar days preserving local time (DST-safe).

### Changed

- `tomorrow` / `yesterday`: Now use calendar day semantics instead of physical time (DST-safe).

## [0.5.2] - 2025-12-27

### Fixed

- `EasyDateTime.parse()`: Correct DST offset resolution for gap/overlap times.

## [0.5.1] - 2025-12-25

### Changed

- Updated READMEs.

## [0.5.0] - 2025-12-25

### Added

- `EasyDateTime.operator ==`: Added support for equality comparison with `DateTime`.

### Changed

- Updated `operator ==` and `hashCode` documentation to clarify behavior and warn about mixed-type usage.

> Thanks to [@timmaffett](https://github.com/timmaffett) ([#19](https://github.com/MasterHiei/easy_date_time/pull/19)).

## [0.4.2] - 2025-12-22

### Fixed

- Documentation: `xxxxx` token (timezone with colon) now documented in `format()` API.

## [0.4.1] - 2025-12-21

### Added

- `DateTimeUnit.week`: ISO 8601 week boundary support for `startOf()` and `endOf()` (Monday = start, Sunday = end).

## [0.4.0] - 2025-12-20

### Added

- `EasyDateTime` now **implements `DateTime`** — true drop-in replacement for any `DateTime` API.
- `startOf(DateTimeUnit)` / `endOf(DateTimeUnit)`: Truncate to time unit boundaries.
- `DateTimeUnit` enum: year, month, day, hour, minute, second.

### Changed

- `==` operator now matches `DateTime` semantics (compares moment + isUtc).
- Updated documentation with clearer equality comparison examples.
- Added intl integration examples.

### Removed

- **BREAKING**: Removed deprecated global functions (use static methods instead):
  - `initializeTimeZone()` → `EasyDateTime.initializeTimeZone()`
  - `setDefaultLocation()` → `EasyDateTime.setDefaultLocation()`
  - `getDefaultLocation()` → `EasyDateTime.getDefaultLocation()`
  - `clearDefaultLocation()` → `EasyDateTime.clearDefaultLocation()`
  - `isTimeZoneInitialized` → `EasyDateTime.isTimeZoneInitialized`

> Thanks to [@timmaffett](https://github.com/timmaffett) ([#12](https://github.com/MasterHiei/easy_date_time/pull/12)).

## [0.3.8] - 2025-12-18

### Added

- `EasyDateTime.timestamp()`: Returns current UTC time, equivalent to `DateTime.timestamp()`.
- `fromSecondsSinceEpoch()`: Added `isUtc` parameter for `DateTime` API compatibility.
- `fromMicrosecondsSinceEpoch()`: Added `isUtc` parameter for `DateTime` API compatibility.

> Thanks to [@timmaffett](https://github.com/timmaffett) ([#16](https://github.com/MasterHiei/easy_date_time/pull/16)).

## [0.3.7] - 2025-12-16

### Added

- `EasyDateTimeFormatter`: Named constructors (`.isoDate()`, `.isoTime()`, `.isoDateTime()`, `.rfc2822()`, `.time12Hour()`, `.time24Hour()`).
- `EasyDateTimeFormatter`: Pattern caching for better performance.
- `EasyDateTimeFormatter.clearCache()`: Clears cached formatters.

> Thanks to [@timmaffett](https://github.com/timmaffett) ([#13](https://github.com/MasterHiei/easy_date_time/pull/13)).

## [0.3.6] - 2025-12-14

### Added

- `fromMillisecondsSinceEpoch()`: Added `isUtc` parameter for `DateTime` compatibility.

> Thanks to [@timmaffett](https://github.com/timmaffett) ([#11](https://github.com/MasterHiei/easy_date_time/pull/11)).

## [0.3.5] - 2025-12-13

### Added

- Format tokens: `EEE` (weekday), `MMM` (month name), `xxxxx`/`xxxx`/`xx`/`X` (timezone offsets).

### Changed

- `DateTimeFormats.rfc2822` now outputs correct RFC 2822 format.

### Removed

- **BREAKING**: Removed the following non-standard format constants:
  - `DateTimeFormats.asianDate`, `usDate`, `euDate`, `fullDateTime`, `fullDateTime12Hour`

  > **Migration**: Use `EasyDateTime.format()` with custom patterns.

## [0.3.4] - 2025-12-12

### Added

- `EasyDateTimeFormatter`: Pre-compiled date format patterns for better loop performance.
- Caching for offset location lookups in parsing module.

## [0.3.3] - 2025-12-11

### Added

- DateTime compatibility constants: `monday`-`sunday`, `january`-`december`, `daysPerWeek`, `monthsPerYear`.
- Static methods: `EasyDateTime.setDefaultLocation()`, `.getDefaultLocation()`, `.clearDefaultLocation()`, `.effectiveDefaultLocation`, `.initializeTimeZone()`, `.isTimeZoneInitialized`.

### Changed

- Fixed undefined `isTimeZoneInitialized` reference in parsing module.

### Deprecated

- Global functions deprecated in favor of static methods (removal in v0.4.0):
  - `initializeTimeZone()` → `EasyDateTime.initializeTimeZone()`
  - `setDefaultLocation()` → `EasyDateTime.setDefaultLocation()`
  - `getDefaultLocation()` → `EasyDateTime.getDefaultLocation()`
  - `clearDefaultLocation()` → `EasyDateTime.clearDefaultLocation()`
  - `isTimeZoneInitialized` → `EasyDateTime.isTimeZoneInitialized`

> Thanks to [@timmaffett](https://github.com/timmaffett) ([#7](https://github.com/MasterHiei/easy_date_time/pull/7)).

## [0.3.2] - 2025-12-11

### Added

- `DateTimeFormats.rfc2822` constant.
- Optimized timezone offset lookup with cached common mappings.

### Fixed

- Fixed quote handling in date formatting logic.
- Verified pre-1970 date handling with boundary tests.

## [0.3.1] - 2025-12-11

### Changed

- Updated package topics in `pubspec.yaml`.
- Updated example documentation to use latest APIs.

## [0.3.0] - 2025-12-10

### Added

- `format(String pattern)`: Flexible date/time formatting with tokens (`yyyy`, `MM`, `dd`, `HH`, `mm`, `ss`, etc.).
- `DateTimeFormats`: Predefined format constants (`isoDate`, `isoTime`, `isoDateTime`, `time12Hour`, `time24Hour`).

## [0.2.2] - 2025-12-09

### Changed

- Updated documentation installation instructions.

### Fixed

- Fixed formatting in `CHANGELOG.md`.

## [0.2.1] - 2025-12-09

### Changed

- Standardized documentation tone across all languages.
- Added CI validation for example code.
- Updated example code to use `fromIso8601String`.

## [0.2.0] - 2025-12-08

### Added

- `fromSecondsSinceEpoch(int seconds, {Location? location})`: Factory for Unix timestamps.
- `fromIso8601String(String dateTimeString)`: Explicit factory for ISO 8601 strings.

### Changed

- **BREAKING**: Renamed `inUtc()` → `toUtc()`, `inLocalTime()` → `toLocal()`, `isAtSameMoment()` → `isAtSameMomentAs()`.
- Modularized codebase into separate parsing and utilities files.

### Removed

- **BREAKING**: Removed `fromJson()` and `toJson()` — Use `fromIso8601String()` and `toIso8601String()`.

## [0.1.2] - 2025-12-07

### Changed

- Updated READMEs.

## [0.1.1] - 2025-12-07

### Added

- Initial release.
