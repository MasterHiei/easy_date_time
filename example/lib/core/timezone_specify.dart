// ignore_for_file: avoid_print

/// Timezone Specification Example
///
/// Demonstrates: three ways to specify timezone.
/// Run: dart run example/02_timezone_specify.dart
library;

import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();

  print('=== Timezone Specification ===\n');

  // --------------------------------------------------------
  // Method 1: TimeZones shortcuts (recommended)
  // --------------------------------------------------------
  print('Method 1: TimeZones shortcuts');
  final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
  final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
  final newYork = EasyDateTime.now(location: TimeZones.newYork);
  final london = EasyDateTime.now(location: TimeZones.london);

  print('  Tokyo:    $tokyo');
  print('  Shanghai: $shanghai');
  print('  New York: $newYork');
  print('  London:   $london');
  print('');

  // --------------------------------------------------------
  // Method 2: getLocation() for any IANA timezone
  // --------------------------------------------------------
  print('Method 2: getLocation()');
  final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
  final dubai = EasyDateTime.now(location: getLocation('Asia/Dubai'));

  print('  Nairobi: $nairobi');
  print('  Dubai:   $dubai');
  print('');

  // --------------------------------------------------------
  // Method 3: Global default
  // --------------------------------------------------------
  print('Method 3: Global default');
  EasyDateTime.setDefaultLocation(TimeZones.shanghai);
  final dt1 = EasyDateTime.now();
  final dt2 = EasyDateTime(2025, 12, 25, 10, 0);

  print('  Set default: Asia/Shanghai');
  print('  now():        $dt1');
  print('  constructor:  $dt2');

  EasyDateTime.clearDefaultLocation();
  print('  Cleared default');
  print('');

  // --------------------------------------------------------
  // Available TimeZones shortcuts
  // --------------------------------------------------------
  print('Available TimeZones:');
  print('  Americas: newYork, losAngeles, chicago, toronto, vancouver');
  print('  Europe:   london, paris, berlin, amsterdam, moscow');
  print('  Asia:     tokyo, shanghai, beijing, hongKong, singapore, seoul');
  print('  Pacific:  sydney, melbourne, auckland');
  print('  Others:   dubai, mumbai, cairo, johannesburg');
}
