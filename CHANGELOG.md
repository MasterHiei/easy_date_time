# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.4] - 2025-12-12

### Added
- **EasyDateTimeFormatter**: Introduced `EasyDateTimeFormatter` class for pre-compiling date format patterns, improving performance in loops.

### Performance
- Added caching for offset location lookups in parsing module.

### Documentation
- Added `EasyDateTimeFormatter` usage examples to READMEs.

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

[0.3.4]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.3.4
[0.3.3]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.3.3
[0.3.2]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.3.2
[0.3.1]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.3.1
[0.3.0]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.3.0
[0.2.2]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.2.2
[0.2.1]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.2.1
[0.2.0]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.2.0
[0.1.2]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.1.2
[0.1.1]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.1.1
