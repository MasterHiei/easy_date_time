// ignore_for_file: avoid_print

/// Date Arithmetic Example
///
/// Demonstrates: adding, subtracting, comparing dates.
/// Run: dart run example/lib/core/arithmetic.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Date Arithmetic ===\n');

  final base = EasyDateTime(2025, 12, 7, 10, 0);
  print('Base: $base\n');

  // --------------------------------------------------------
  // Addition with Duration extensions
  // --------------------------------------------------------
  print('Addition:');
  print('  + 1.days:    ${base + 1.days}');
  print('  + 1.weeks:   ${base + 1.weeks}');
  print('  + 2.hours:   ${base + 2.hours}');
  print('  + 30.minutes: ${base + 30.minutes}');
  print('  + combined:  ${base + 1.days + 2.hours + 30.minutes}');
  print('');

  // --------------------------------------------------------
  // Subtraction
  // --------------------------------------------------------
  print('Subtraction:');
  print('  - 1.days:    ${base - 1.days}');
  print('  - 1.weeks:   ${base - 1.weeks}');
  print('  - 30.days:   ${base - 30.days}');
  print('');

  // --------------------------------------------------------
  // Comparison operators
  // --------------------------------------------------------
  print('Comparison:');
  final future = base + 1.days;
  final past = base - 1.days;
  print('  base: $base');
  print('  future: $future');
  print('  past: $past');
  print('');
  print('  base < future:  ${base < future}');
  print('  base > past:    ${base > past}');
  print('  base <= base:   ${base <= base}');
  print('  base >= base:   ${base >= base}');
  print('');

  // --------------------------------------------------------
  // Comparison methods
  // --------------------------------------------------------
  print('Comparison methods:');
  print('  base.isBefore(future): ${base.isBefore(future)}');
  print('  base.isAfter(past):    ${base.isAfter(past)}');
  print('');

  // --------------------------------------------------------
  // Difference
  // --------------------------------------------------------
  print('Difference:');
  final diff = future.difference(base);
  print('  future - base = $diff');
  print('  In days: ${diff.inDays}');
  print('  In hours: ${diff.inHours}');
  print('');

  // --------------------------------------------------------
  // Duration extensions
  // --------------------------------------------------------
  print('Duration extensions:');
  print('  1.weeks       = ${1.weeks}');
  print('  3.days        = ${3.days}');
  print('  2.hours       = ${2.hours}');
  print('  30.minutes    = ${30.minutes}');
  print('  45.seconds    = ${45.seconds}');
  print('  100.milliseconds = ${100.milliseconds}');
}
