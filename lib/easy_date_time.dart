/// A timezone-aware DateTime library for Dart.
///
/// This library provides [EasyDateTime], a drop-in replacement for Dart's
/// [DateTime] that supports timezone-aware operations.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:easy_date_time/easy_date_time.dart';
///
/// void main() {
///   initializeTimeZone();  // Required - call once at startup
///
///   final now = EasyDateTime.now();  // Local time
///   final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
///
///   // Parse with timezone preserved
///   final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
///   print(dt.hour);  // 10 (not converted!)
/// }
/// ```
///
/// ## Features
///
/// - **Timezone Support**: Any IANA timezone (Asia/Tokyo, America/New_York, etc.)
/// - **Time Preservation**: `parse()` preserves original time values
/// - **Operators**: `+`, `-`, `<`, `>`, `==` for intuitive operations
/// - **JSON Serialization**: ISO 8601 format, works with json_serializable
/// - **Immutable**: Thread-safe, works with riverpod/bloc/freezed
library;

// Re-export Location and getLocation from timezone package
export 'package:timezone/timezone.dart' show Location, getLocation;

export 'src/easy_date_time.dart';
export 'src/easy_date_time_config.dart';
export 'src/easy_date_time_init.dart';
export 'src/exceptions/exceptions.dart';
export 'src/extensions/date_time_extension.dart';
export 'src/extensions/duration_extension.dart';

export 'src/timezones.dart';

// DateTimeFormats is exported automatically as part of src/easy_date_time.dart
