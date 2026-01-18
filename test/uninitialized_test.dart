/// Tests behavior BEFORE initialization.
///
/// This file must run in isolation (or before any other test calls [initializeTimeZone])
/// to correctly verify the [TimeZoneNotInitializedException] behavior.
library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  group('Uninitialized TimeZone behavior', () {
    test('isTimeZoneInitialized returns false when database fail', () {
      expect(EasyDateTime.isTimeZoneInitialized, isFalse);
    });

    test('effectiveDefaultLocation throws TimeZoneNotInitializedException', () {
      expect(
        () => EasyDateTime.effectiveDefaultLocation,
        throwsA(isA<TimeZoneNotInitializedException>()),
      );
    });

    test('EasyDateTime.now() throws TimeZoneNotInitializedException', () {
      expect(
        () => EasyDateTime.now(),
        throwsA(isA<TimeZoneNotInitializedException>()),
      );
    });

    test('EasyDateTime constructor throws TimeZoneNotInitializedException', () {
      expect(
        () => EasyDateTime(2025, 1, 1),
        throwsA(isA<TimeZoneNotInitializedException>()),
      );
    });

    test('TimeZones getter throws TimeZoneNotInitializedException', () {
      expect(
        () => TimeZones.shanghai,
        throwsA(isA<TimeZoneNotInitializedException>()),
      );
    });

    test('TimeZones.utc throws TimeZoneNotInitializedException', () {
      expect(
        () => TimeZones.utc,
        throwsA(isA<TimeZoneNotInitializedException>()),
      );
    });

    test('TimeZones.tryGet throws TimeZoneNotInitializedException', () {
      expect(
        () => TimeZones.tryGet('UTC'),
        throwsA(isA<TimeZoneNotInitializedException>()),
      );
    });

    test('TimeZones.isValid throws TimeZoneNotInitializedException', () {
      expect(
        () => TimeZones.isValid('UTC'),
        throwsA(isA<TimeZoneNotInitializedException>()),
      );
    });
  });
}
