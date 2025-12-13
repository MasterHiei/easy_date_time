// ignore_for_file: avoid_print

/// Date Utilities Example
///
/// Demonstrates: isToday, startOfDay, endOfMonth, etc.
/// Run: dart run example/06_date_utils.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Date Utilities ===\n');

  final now = EasyDateTime.now();
  print('Now: $now\n');

  // --------------------------------------------------------
  // Today checks
  // --------------------------------------------------------
  print('Today checks:');
  print('  isToday:     ${now.isToday}');
  print('  isTomorrow:  ${now.isTomorrow}');
  print('  isYesterday: ${now.isYesterday}');
  print('');

  // --------------------------------------------------------
  // Navigation
  // --------------------------------------------------------
  print('Navigation:');
  print('  tomorrow:  ${now.tomorrow.toDateString()}');
  print('  yesterday: ${now.yesterday.toDateString()}');
  print('');

  // --------------------------------------------------------
  // Day boundaries
  // --------------------------------------------------------
  print('Day boundaries:');
  print('  startOfDay: ${now.startOfDay}');
  print('  endOfDay:   ${now.endOfDay}');
  print('');

  // --------------------------------------------------------
  // Month boundaries
  // --------------------------------------------------------
  print('Month boundaries:');
  print('  startOfMonth: ${now.startOfMonth.toDateString()}');
  print('  endOfMonth:   ${now.endOfMonth.toDateString()}');
  print('');

  // --------------------------------------------------------
  // dateOnly (time set to 00:00:00)
  // --------------------------------------------------------
  print('Date only:');
  final withTime = EasyDateTime(2025, 12, 7, 15, 30, 45);
  print('  Original: $withTime');
  print('  dateOnly: ${withTime.dateOnly}');
  print('');

  // --------------------------------------------------------
  // Practical: Date range check
  // --------------------------------------------------------
  print('Practical: Date range check');
  final eventStart = EasyDateTime(2025, 12, 1);
  final eventEnd = EasyDateTime(2025, 12, 31);

  print('  Event: ${eventStart.toDateString()} ~ ${eventEnd.toDateString()}');
  print('  Now in range: ${now.isAfter(eventStart) && now.isBefore(eventEnd)}');

  if (now.isBefore(eventEnd)) {
    final remaining = eventEnd.difference(now);
    print('  Days remaining: ${remaining.inDays}');
  }
}
