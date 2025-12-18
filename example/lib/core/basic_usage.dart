// ignore_for_file: avoid_print

/// Basic Usage Example
///
/// Demonstrates: initialization, creating, and basic operations.
/// Run: dart run example/lib/core/basic_usage.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Basic Usage ===\n');

  // Create current time
  final now = EasyDateTime.now();
  print('Now: $now');
  print('  Year: ${now.year}');
  print('  Month: ${now.month}');
  print('  Day: ${now.day}');
  print('  Hour: ${now.hour}');
  print('  Minute: ${now.minute}');
  print('  Weekday: ${now.weekday}');
  print('  Timezone: ${now.locationName}');
  print('');

  // Create from components
  final christmas = EasyDateTime(2025, 12, 25, 10, 30);
  print('Christmas: $christmas');
  print('');

  // Create UTC time
  final utcTime = EasyDateTime.utc(2025, 12, 25, 0, 0);
  print('UTC: $utcTime');
  print('');

  // DateTime interoperability
  final dartDateTime = DateTime.now();
  final fromDart = dartDateTime.toEasyDateTime();
  print('From DateTime: $fromDart');

  final backToDart = now.toDateTime();
  print('To DateTime: $backToDart');
}
