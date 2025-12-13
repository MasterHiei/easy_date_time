// ignore_for_file: avoid_print

/// Parsing Example
///
/// Demonstrates: parsing timestamps with preserved original values.
/// Run: dart run example/03_parsing.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Parsing (Time Value Preservation) ===\n');

  // --------------------------------------------------------
  // Core behavior: Original time values are preserved
  // --------------------------------------------------------
  print('Parsing with timezone offset:');
  final dt1 = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
  print('  Input:    "2025-12-07T10:30:00+08:00"');
  print('  Hour:     ${dt1.hour} (preserved, not 02!)');
  print('  Location: ${dt1.locationName}');
  print('');

  final dt2 = EasyDateTime.parse('2025-12-07T15:00:00+09:00');
  print('  Input:    "2025-12-07T15:00:00+09:00"');
  print('  Hour:     ${dt2.hour} (preserved)');
  print('  Location: ${dt2.locationName}');
  print('');

  // --------------------------------------------------------
  // UTC parsing
  // --------------------------------------------------------
  print('Parsing UTC:');
  final utc = EasyDateTime.parse('2025-12-07T10:30:00Z');
  print('  Input:    "2025-12-07T10:30:00Z"');
  print('  Hour:     ${utc.hour}');
  print('  Location: ${utc.locationName}');
  print('');

  // --------------------------------------------------------
  // Explicit conversion (only when requested)
  // --------------------------------------------------------
  print('Explicit conversion:');
  final converted = EasyDateTime.parse(
    '2025-12-07T10:30:00Z',
    location: TimeZones.newYork,
  );
  print('  Input:    "2025-12-07T10:30:00Z" with location: New York');
  print('  Hour:     ${converted.hour} (10 UTC → 5 NY)');
  print('  Location: ${converted.locationName}');
  print('');

  // --------------------------------------------------------
  // Same moment verification
  // --------------------------------------------------------
  print('Same moment verification:');
  final shanghai = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
  final tokyo = EasyDateTime.parse('2025-12-07T11:30:00+09:00');
  print('  Shanghai 10:30+08:00');
  print('  Tokyo    11:30+09:00');
  print('  Same moment: ${shanghai.isAtSameMomentAs(tokyo)}');
  print('');

  // --------------------------------------------------------
  // Safe parsing with tryParse
  // --------------------------------------------------------
  print('Safe parsing (tryParse):');
  final valid = EasyDateTime.tryParse('2025-12-07T10:30:00Z');
  final invalid = EasyDateTime.tryParse('not-a-date');
  print('  Valid input:   $valid');
  print('  Invalid input: $invalid');
}
