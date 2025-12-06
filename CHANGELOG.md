# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0+1] - 2025-12-07

Initial release of `easy_date_time` package.

### Core Features

- **EasyDateTime class** - Timezone-aware DateTime implementation
- **Local timezone as default** - Works immediately without configuration
- **TimeZones convenience API** - 30+ common timezones with easy accessors

### Project Configuration

- **CI/CD Pipeline** - Automated testing and Gitflow-based release workflow (`release.yml`)
- **Community Standards** - Added `CONTRIBUTING.md`, Code of Conduct, and GitHub Templates
- **Development Experience** - Configured `lints` and strict analysis options

### Constructors

- `EasyDateTime()` - From date/time components
- `EasyDateTime.now()` - Current time
- `EasyDateTime.utc()` - UTC time
- `EasyDateTime.fromDateTime()` - From standard DateTime
- `EasyDateTime.fromMillisecondsSinceEpoch()` / `fromMicrosecondsSinceEpoch()`
- `EasyDateTime.parse()` / `tryParse()` - Parse ISO 8601 strings

### Date Utilities

- `dateOnly` / `startOfDay` - Get date without time (00:00:00)
- `endOfDay` - Last moment of the day (23:59:59.999999)
- `startOfMonth` / `endOfMonth` - First/last moment of month
- `tomorrow` / `yesterday` - Next/previous day
- `isToday` / `isTomorrow` / `isYesterday` - Date checking
- `toDateString()` / `toTimeString()` - Formatted output

### Timezone Operations

- `inLocation()` - Convert to specific timezone
- `inUtc()` - Convert to UTC
- `inLocalTime()` - Convert to local time
- `setDefaultLocation()` / `clearDefaultLocation()` - Global timezone config

### Operators & Comparison

- Arithmetic: `+`, `-` with Duration
- Comparison: `<`, `>`, `<=`, `>=`, `==`
- Methods: `isBefore()`, `isAfter()`, `isAtSameMoment()`

### Extensions

- **Duration**: `1.days`, `2.hours`, `30.minutes`, etc.
- **DateTime**: `toEasyDateTime()` for easy conversion

### Serialization

- `toJson()` / `fromJson()` - ISO 8601 format
- Compatible with json_serializable, freezed

[0.1.0+1]: https://github.com/MasterHiei/easy_date_time/releases/tag/v0.1.0+1
