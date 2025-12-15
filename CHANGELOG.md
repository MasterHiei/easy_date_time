# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.7] - 2025-12-16

### Added
- `EasyDateTimeFormatter`: Named constructors (`.isoDate()`, `.isoTime()`, `.isoDateTime()`, `.rfc2822()`, `.time12Hour()`, `.time24Hour()`).
- `EasyDateTimeFormatter`: Pattern caching for better performance in repeated use.
- `EasyDateTimeFormatter.clearCache()`: Clears cached formatters for long-running apps.

### Contributors
Thanks to [@timmaffett](https://github.com/timmaffett) for this release ([#13](https://github.com/MasterHiei/easy_date_time/pull/13)).

## [0.3.6] - 2025-12-14

### Added
- `fromMillisecondsSinceEpoch()`: Added `isUtc` parameter for `DateTime` compatibility.

### Documentation
- Improved `fromMillisecondsSinceEpoch()` API docs with examples.

### Contributors
Thanks to [@timmaffett](https://github.com/timmaffett) for this release ([#11](https://github.com/MasterHiei/easy_date_time/pull/11)).

## [0.3.5] - 2025-12-13

### ⚠️ Breaking Changes
- **Removed Constants**: The following non-standard/ambiguous formats were removed:
  - `DateTimeFormats.asianDate`
  - `DateTimeFormats.usDate`
  - `DateTimeFormats.euDate`
  - `DateTimeFormats.fullDateTime`
  - `DateTimeFormats.fullDateTime12Hour`
  > **Migration**: Use `EasyDateTime.format()` with custom patterns if needed.

### Added
- **New Format Tokens**:
  - `EEE` - Day of week (Mon, Tue...)
  - `MMM` - Month name (Jan, Feb...)
  - `xxxxx` - Timezone offset with colon (+08:00)
  - `xxxx` - Timezone offset (+0800)
  - `xx` - Timezone offset short (+08)
  - `X` - ISO timezone (Z or +0800)

### Fixed
- **RFC 2822 Compliance**: `DateTimeFormats.rfc2822` now correctly outputs `Mon, 01 Dec 2025 14:30:45 +0800`.

## [0.3.4] - 2025-12-12

### Added
- **EasyDateTimeFormatter**: Introduced `EasyDateTimeFormatter` class for pre-compiling date format patterns, improving performance in loops.

### Performance
- Added caching for offset location lookups in parsing module.

### Documentation
- Added `EasyDateTimeFormatter` usage examples to READMEs.
- Added `formatter_example.dart` to example README.

## [0.3.3] - 2025-12-11

### Added
- **DateTime Compatibility Constants**: Added weekday and month constants for drop-in compatibility with `DateTime`:
  - Weekday: `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday`, `sunday`, `daysPerWeek`
  - Month: `january`, `february`, `march`, `april`, `may`, `june`, `july`, `august`, `september`, `october`, `november`, `december`, `monthsPerYear`
- **Static Configuration Methods**: Added static methods on `EasyDateTime` class for clearer package context:
  - `EasyDateTime.setDefaultLocation()` - Sets global default timezone
  - `EasyDateTime.getDefaultLocation()` - Gets current global default
  - `EasyDateTime.clearDefaultLocation()` - Clears global default
  - `EasyDateTime.effectiveDefaultLocation` - Gets effective default location
  - `EasyDateTime.initializeTimeZone()` - Initializes timezone database
  - `EasyDateTime.isTimeZoneInitialized` - Checks initialization status

### Deprecated
- **Global functions deprecated in favor of static methods** (will be removed in v0.4.0):
  - `initializeTimeZone()` → Use `EasyDateTime.initializeTimeZone()`
  - `setDefaultLocation()` → Use `EasyDateTime.setDefaultLocation()`
  - `getDefaultLocation()` → Use `EasyDateTime.getDefaultLocation()`
  - `clearDefaultLocation()` → Use `EasyDateTime.clearDefaultLocation()`
  - `isTimeZoneInitialized` → Use `EasyDateTime.isTimeZoneInitialized`

### Fixed
- Fixed undefined `isTimeZoneInitialized` reference in parsing module

### Contributors
Thanks to [@timmaffett](https://github.com/timmaffett) for this release ([#7](https://github.com/MasterHiei/easy_date_time/pull/7)).

## [0.3.2] - 2025-12-11

### Added
- Added `DateTimeFormats.rfc2822` constant (`dd MM yyyy HH:mm:ss`).

### Fixed
- Fixed quote handling in date formatting logic.

### Verified
- Verified correctness of pre-1970 date handling with new boundary tests.

### Performance
- Optimized timezone offset lookup with cached common mappings.

### CI
- Expanded compatibility matrix to include all OSs (Ubuntu, macOS, Windows).

## [0.3.1] - 2025-12-11

### Changed
- Updated package topics in `pubspec.yaml`.

### Fixed
- Updated example documentation to use latest APIs.

## [0.3.0] - 2025-12-10

### Added
- **Date Formatting API**: New `format(String pattern)` method for flexible date/time formatting
  - Supports tokens: `yyyy`, `yy`, `MM`, `M`, `dd`, `d`, `HH`, `H`, `hh`, `h`, `mm`, `m`, `ss`, `s`, `SSS`, `S`, `a`
  - Supports escaped literal text using single quotes
  - Works correctly with all timezones including DST transitions
- **DateTimeFormats**: Predefined format constants for common patterns
  - `isoDate` (`yyyy-MM-dd`)
  - `isoTime` (`HH:mm:ss`)
  - `isoDateTime` (`yyyy-MM-ddTHH:mm:ss`)
  - `usDate` (`MM/dd/yyyy`)
  - `euDate` (`dd/MM/yyyy`)
  - `asianDate` (`yyyy/MM/dd`)
  - `time12Hour` (`hh:mm a`)
  - `time24Hour` (`HH:mm`)
  - `fullDateTime` (`yyyy-MM-dd HH:mm:ss`)
  - `fullDateTime12Hour` (`yyyy-MM-dd hh:mm:ss a`)

## [0.2.2] - 2025-12-09

### Fixed
- Fixed formatting in `CHANGELOG.md`.
- Updated documentation installation instructions to latest version.

## [0.2.1] - 2025-12-09

### Fixed
- Updated example code to use `fromIso8601String` instead of removed APIs.

### Changed
- Standardized documentation tone and navigation across all languages.
- Added CI validation for example code.

## [0.2.0] - 2025-12-08

### ⚠️ Breaking Changes
- **Renamed** `inUtc()` → `toUtc()` — Consistent with `DateTime.toUtc()`
- **Renamed** `inLocalTime()` → `toLocal()` — Consistent with `DateTime.toLocal()`
- **Renamed** `isAtSameMoment()` → `isAtSameMomentAs()` — Consistent with `DateTime.isAtSameMomentAs()`
- **Removed** `fromJson()` and `toJson()` — Use `fromIso8601String()` and `toIso8601String()` instead

### Added
- `fromSecondsSinceEpoch(int seconds, {Location? location})` — Factory for Unix timestamps in seconds
- `fromIso8601String(String dateTimeString)` — Explicit factory for ISO 8601 strings

### Changed
- Modularized codebase: split `easy_date_time.dart` into `easy_date_time_parsing.dart` and `easy_date_time_utilities.dart`
- Improved documentation and code comments

## [0.1.2] - 2025-12-07

- Update READMEs.

## [0.1.1] - 2025-12-07

- Initial release of `easy_date_time` package.
