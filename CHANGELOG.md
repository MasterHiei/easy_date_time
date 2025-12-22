# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2025-12-22

### Fixed
- Documentation: `xxxxx` token (timezone with colon) now documented in `format()` API

## [0.4.1] - 2025-12-21

### Added
- `DateTimeUnit.week`: ISO 8601 week boundary support for `startOf()` and `endOf()` (Monday = start, Sunday = end)

## [0.4.0] - 2025-12-20

### ⚠️ Breaking Changes
- **Removed deprecated global functions** (use static methods instead):
  - `initializeTimeZone()` → `EasyDateTime.initializeTimeZone()`
  - `setDefaultLocation()` → `EasyDateTime.setDefaultLocation()`
  - `getDefaultLocation()` → `EasyDateTime.getDefaultLocation()`
  - `clearDefaultLocation()` → `EasyDateTime.clearDefaultLocation()`
  - `isTimeZoneInitialized` → `EasyDateTime.isTimeZoneInitialized`

### Added
- `EasyDateTime` now **implements `DateTime`** — true drop-in replacement for any `DateTime` API
- `startOf(DateTimeUnit)` / `endOf(DateTimeUnit)`: Truncate to time unit boundaries
- `DateTimeUnit` enum: year, month, day, hour, minute, second

### Changed
- `==` operator now matches `DateTime` semantics (compares moment + isUtc)
- Updated documentation with clearer equality comparison examples
- Added intl integration examples

### Contributors
- Thanks to [@timmaffett](https://github.com/timmaffett) for this release ([#12](https://github.com/MasterHiei/easy_date_time/pull/12)).

## [0.3.8] - 2025-12-18

### Added
- `EasyDateTime.timestamp()`: Returns current UTC time, equivalent to `DateTime.timestamp()`.
- `fromSecondsSinceEpoch()`: Added `isUtc` parameter for `DateTime` API compatibility.
- `fromMicrosecondsSinceEpoch()`: Added `isUtc` parameter for `DateTime` API compatibility.

### Contributors
Thanks to [@timmaffett](https://github.com/timmaffett) for this release ([#16](https://github.com/MasterHiei/easy_date_time/pull/16)).

## [0.3.7] - 2025-12-16

### Added
- `EasyDateTimeFormatter`: Named constructors (`.isoDate()`, `.isoTime()`, `.isoDateTime()`, `.rfc2822()`, `.time12Hour()`, `.time24Hour()`).
- `EasyDateTimeFormatter`: Pattern caching for better performance.
- `EasyDateTimeFormatter.clearCache()`: Clears cached formatters.

### Contributors
Thanks to [@timmaffett](https://github.com/timmaffett) for this release ([#13](https://github.com/MasterHiei/easy_date_time/pull/13)).

## [0.3.6] - 2025-12-14

### Added
- `fromMillisecondsSinceEpoch()`: Added `isUtc` parameter for `DateTime` compatibility.

### Contributors
Thanks to [@timmaffett](https://github.com/timmaffett) for this release ([#11](https://github.com/MasterHiei/easy_date_time/pull/11)).

## [0.3.5] - 2025-12-13

### ⚠️ Breaking Changes
- **Removed Constants**: The following non-standard formats were removed:
  - `DateTimeFormats.asianDate`, `usDate`, `euDate`, `fullDateTime`, `fullDateTime12Hour`
  > **Migration**: Use `EasyDateTime.format()` with custom patterns.

### Added
- Format tokens: `EEE` (weekday), `MMM` (month name), `xxxxx`/`xxxx`/`xx`/`X` (timezone offsets).

### Fixed
- `DateTimeFormats.rfc2822` now outputs correct RFC 2822 format.

## [0.3.4] - 2025-12-12

### Added
- `EasyDateTimeFormatter`: Pre-compiled date format patterns for better loop performance.
- Caching for offset location lookups in parsing module.

## [0.3.3] - 2025-12-11

### Added
- DateTime compatibility constants: `monday`-`sunday`, `january`-`december`, `daysPerWeek`, `monthsPerYear`.
- Static methods: `EasyDateTime.setDefaultLocation()`, `.getDefaultLocation()`, `.clearDefaultLocation()`, `.effectiveDefaultLocation`, `.initializeTimeZone()`, `.isTimeZoneInitialized`.

### Deprecated
- Global functions deprecated in favor of static methods (removal in v0.4.0):
  - `initializeTimeZone()` → `EasyDateTime.initializeTimeZone()`
  - `setDefaultLocation()` → `EasyDateTime.setDefaultLocation()`
  - `getDefaultLocation()` → `EasyDateTime.getDefaultLocation()`
  - `clearDefaultLocation()` → `EasyDateTime.clearDefaultLocation()`
  - `isTimeZoneInitialized` → `EasyDateTime.isTimeZoneInitialized`

### Fixed
- Fixed undefined `isTimeZoneInitialized` reference in parsing module.

### Contributors
Thanks to [@timmaffett](https://github.com/timmaffett) for this release ([#7](https://github.com/MasterHiei/easy_date_time/pull/7)).

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

### Fixed
- Updated example documentation to use latest APIs.

## [0.3.0] - 2025-12-10

### Added
- `format(String pattern)`: Flexible date/time formatting with tokens (`yyyy`, `MM`, `dd`, `HH`, `mm`, `ss`, etc.).
- `DateTimeFormats`: Predefined format constants (`isoDate`, `isoTime`, `isoDateTime`, `time12Hour`, `time24Hour`).

## [0.2.2] - 2025-12-09

### Fixed
- Fixed formatting in `CHANGELOG.md`.
- Updated documentation installation instructions.

## [0.2.1] - 2025-12-09

### Fixed
- Updated example code to use `fromIso8601String`.

### Changed
- Standardized documentation tone across all languages.
- Added CI validation for example code.

## [0.2.0] - 2025-12-08

### ⚠️ Breaking Changes
- Renamed `inUtc()` → `toUtc()`, `inLocalTime()` → `toLocal()`, `isAtSameMoment()` → `isAtSameMomentAs()`.
- Removed `fromJson()` and `toJson()` — Use `fromIso8601String()` and `toIso8601String()`.

### Added
- `fromSecondsSinceEpoch(int seconds, {Location? location})`: Factory for Unix timestamps.
- `fromIso8601String(String dateTimeString)`: Explicit factory for ISO 8601 strings.

### Changed
- Modularized codebase into separate parsing and utilities files.

## [0.1.2] - 2025-12-07

- Updated READMEs.

## [0.1.1] - 2025-12-07

- Initial release.
