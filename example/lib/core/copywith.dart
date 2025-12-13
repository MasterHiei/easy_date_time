// ignore_for_file: avoid_print

/// copyWith Example
///
/// Demonstrates: creating modified copies.
/// Run: dart run example/09_copywith.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== copyWith ===\n');

  final original = EasyDateTime(2025, 12, 7, 10, 30, 0, 0, 0, TimeZones.tokyo);
  print('Original: $original\n');

  // --------------------------------------------------------
  // Change single field
  // --------------------------------------------------------
  print('Change single field:');
  print('  year → 2026:   ${original.copyWith(year: 2026)}');
  print('  month → 6:     ${original.copyWith(month: 6)}');
  print('  day → 25:      ${original.copyWith(day: 25)}');
  print('  hour → 15:     ${original.copyWith(hour: 15)}');
  print('  minute → 0:    ${original.copyWith(minute: 0)}');
  print('');

  // --------------------------------------------------------
  // Change multiple fields
  // --------------------------------------------------------
  print('Change multiple fields:');
  final modified = original.copyWith(
    month: 1,
    day: 1,
    hour: 0,
    minute: 0,
    second: 0,
  );
  print('  New Year: $modified');
  print('');

  // --------------------------------------------------------
  // Change timezone
  // --------------------------------------------------------
  print('Change timezone:');
  final inNY = original.copyWith(location: TimeZones.newYork);
  print('  → New York: $inNY');
  print('');

  // --------------------------------------------------------
  // Practical: Schedule recurrence
  // --------------------------------------------------------
  print('Practical: Weekly meeting schedule');
  final meeting = EasyDateTime(2025, 12, 7, 14, 0);
  print('  Week 1: ${meeting.toDateString()}');
  print('  Week 2: ${meeting.copyWith(day: meeting.day + 7).toDateString()}');
  print('  Week 3: ${meeting.copyWith(day: meeting.day + 14).toDateString()}');
  print('  Week 4: ${meeting.copyWith(day: meeting.day + 21).toDateString()}');
}
