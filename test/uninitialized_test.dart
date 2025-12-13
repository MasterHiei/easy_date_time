import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  group('Uninitialized TimeZone behavior', () {
    // IMPORTANT: Do NOT call EasyDateTime.initializeTimeZone() in this file
    // These tests verify exception behavior when NOT initialized.

    test('isTimeZoneInitialized returns false', () {
      expect(EasyDateTime.isTimeZoneInitialized, isFalse);
    });

    test('effectiveDefaultLocation throws TimeZoneNotInitializedException', () {
      expect(
        () => effectiveDefaultLocation,
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

    test('TimeZones.isValid throws TimeZoneNotInitializedException', () {
      expect(
        () => TimeZones.isValid('UTC'),
        throwsA(isA<TimeZoneNotInitializedException>()),
      );
    });

    test('TimeZones.tryGet throws TimeZoneNotInitializedException', () {
      expect(
        () => TimeZones.tryGet('UTC'),
        throwsA(isA<TimeZoneNotInitializedException>()),
      );
    });

    test('Exception has helpful message', () {
      try {
        effectiveDefaultLocation;
        fail('Should have thrown');
      } on TimeZoneNotInitializedException catch (e) {
        expect(e.message, contains('initializeTimeZone'));
        expect(e.toString(), contains('TimeZoneNotInitializedException'));
      }
    });
  });
}
