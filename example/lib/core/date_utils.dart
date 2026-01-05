// ignore_for_file: avoid_print

/// Date Utilities Example
///
/// Demonstrates date utility methods:
/// - Day checks: isToday, isTomorrow, isYesterday
/// - Navigation: tomorrow, yesterday, addCalendarDays, subtractCalendarDays
/// - Boundaries: startOfDay, endOfDay, startOfMonth, endOfMonth, startOf, endOf
/// - Properties: dayOfYear, weekOfYear, daysInMonth, isLeapYear, isWeekend, isWeekday, quarter
///
/// Run: dart run example/lib/core/date_utils.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Date Utilities ===\n');

  final now = EasyDateTime.now();
  print('Current time: $now\n');

  // --------------------------------------------------------
  // Day checks
  // --------------------------------------------------------
  print('Day checks:');
  print('  isToday:     ${now.isToday}');
  print('  isTomorrow:  ${now.isTomorrow}');
  print('  isYesterday: ${now.isYesterday}');
  print('');

  // --------------------------------------------------------
  // Day navigation
  // --------------------------------------------------------
  print('Day navigation:');
  print('  tomorrow:  ${now.tomorrow.toDateString()}');
  print('  yesterday: ${now.yesterday.toDateString()}');
  print('');

  // --------------------------------------------------------
  // Calendar day arithmetic (DST-safe)
  // --------------------------------------------------------
  print('Calendar day arithmetic:');
  final march1 = EasyDateTime(2025, 3, 1, 12, 30);
  print('  Start:               $march1');
  print('  + 10 calendar days:  ${march1.addCalendarDays(10)}');
  print('  - 5 calendar days:   ${march1.subtractCalendarDays(5)}');
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
  // dateOnly
  // --------------------------------------------------------
  print('dateOnly (strips time to 00:00:00):');
  final withTime = EasyDateTime(2025, 12, 7, 15, 30, 45);
  print('  Before: $withTime');
  print('  After:  ${withTime.dateOnly}');
  print('');

  // --------------------------------------------------------
  // startOf / endOf with DateTimeUnit
  // --------------------------------------------------------
  print('startOf / endOf:');
  final sample = EasyDateTime(2025, 6, 15, 14, 30, 45);
  print('  Input:          $sample');
  print('  startOf(day):   ${sample.startOf(DateTimeUnit.day)}');
  print('  endOf(month):   ${sample.endOf(DateTimeUnit.month)}');
  print('  startOf(year):  ${sample.startOf(DateTimeUnit.year)}');
  print('');

  // --------------------------------------------------------
  // Date range check (practical example)
  // --------------------------------------------------------
  print('Date range check:');
  final eventStart = EasyDateTime(2025, 12, 1);
  final eventEnd = EasyDateTime(2025, 12, 31);
  final inRange = now.isAfter(eventStart) && now.isBefore(eventEnd);
  print(
      '  Event period: ${eventStart.toDateString()} ~ ${eventEnd.toDateString()}');
  print('  Current date in range: $inRange');
  print('');

  // --------------------------------------------------------
  // dayOfYear & weekOfYear
  // --------------------------------------------------------
  print('Day of year and week of year:');
  final june15 = EasyDateTime(2025, 6, 15);
  print(
      '  2025-06-15: day ${june15.dayOfYear} of year, week ${june15.weekOfYear}');
  print(
      '  2025-01-01: day ${EasyDateTime(2025, 1, 1).dayOfYear}, week ${EasyDateTime(2025, 1, 1).weekOfYear}');
  print(
      '  2025-12-31: day ${EasyDateTime(2025, 12, 31).dayOfYear}, week ${EasyDateTime(2025, 12, 31).weekOfYear}');
  print('');

  // --------------------------------------------------------
  // daysInMonth & isLeapYear
  // --------------------------------------------------------
  print('Month days and leap year:');
  final feb2024 = EasyDateTime(2024, 2, 15);
  final feb2025 = EasyDateTime(2025, 2, 15);
  print(
      '  Feb 2024: ${feb2024.daysInMonth} days (leap year: ${feb2024.isLeapYear})');
  print(
      '  Feb 2025: ${feb2025.daysInMonth} days (leap year: ${feb2025.isLeapYear})');
  print('');

  // --------------------------------------------------------
  // isWeekend / isWeekday
  // --------------------------------------------------------
  print('Weekend and weekday:');
  final saturday = EasyDateTime(2025, 1, 4); // Saturday
  final monday = EasyDateTime(2025, 1, 6); // Monday
  print(
      '  2025-01-04 (Sat): isWeekend=${saturday.isWeekend}, isWeekday=${saturday.isWeekday}');
  print(
      '  2025-01-06 (Mon): isWeekend=${monday.isWeekend}, isWeekday=${monday.isWeekday}');
  print('');

  // --------------------------------------------------------
  // quarter
  // --------------------------------------------------------
  print('Quarter:');
  print('  Jan 15 -> Q${EasyDateTime(2025, 1, 15).quarter}');
  print('  Apr 15 -> Q${EasyDateTime(2025, 4, 15).quarter}');
  print('  Jul 15 -> Q${EasyDateTime(2025, 7, 15).quarter}');
  print('  Oct 15 -> Q${EasyDateTime(2025, 10, 15).quarter}');
}
