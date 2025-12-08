# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.2.1]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.2.1
[0.2.0]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.2.0
[0.1.2]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.1.2
[0.1.1]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.1.1
