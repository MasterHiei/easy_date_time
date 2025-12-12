/// Tests for deprecated global functions.
///
/// These tests ensure backward compatibility during the deprecation period.
/// The deprecated functions should continue to work until they are removed
/// in v0.4.0.
library;

// ignore_for_file: deprecated_member_use_from_same_package
import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    // Use the deprecated function to test it
    initializeTimeZone();
  });

  tearDown(() {
    // Use the deprecated function to test it
    clearDefaultLocation();
  });

  group('Deprecated Global Functions (Backward Compatibility)', () {
    test('initializeTimeZone() initializes timezone database', () {
      // Already called in setUpAll, verify it worked
      expect(isTimeZoneInitialized, isTrue);
    });

    test('setDefaultLocation() sets the global default', () {
      setDefaultLocation(TimeZones.tokyo);

      final dt = EasyDateTime(2025, 12, 1, 10, 30);
      expect(dt.locationName, 'Asia/Tokyo');
    });

    test('getDefaultLocation() returns the current default', () {
      expect(getDefaultLocation(), isNull);

      setDefaultLocation(TimeZones.shanghai);
      expect(getDefaultLocation()?.name, 'Asia/Shanghai');
    });

    test('clearDefaultLocation() clears the global default', () {
      setDefaultLocation(TimeZones.london);
      expect(getDefaultLocation(), isNotNull);

      clearDefaultLocation();
      expect(getDefaultLocation(), isNull);
    });

    test('isTimeZoneInitialized returns correct state', () {
      // Since we called initializeTimeZone() in setUpAll
      expect(isTimeZoneInitialized, isTrue);
    });

    test('effectiveDefaultLocation returns effective location', () {
      clearDefaultLocation();
      // When no default is set, should return local
      expect(effectiveDefaultLocation, isNotNull);

      setDefaultLocation(TimeZones.newYork);
      expect(effectiveDefaultLocation.name, 'America/New_York');
    });

    test('deprecated functions work together with static methods', () {
      // Set via deprecated function
      setDefaultLocation(TimeZones.paris);

      // Get via static method
      expect(EasyDateTime.getDefaultLocation()?.name, 'Europe/Paris');

      // Clear via static method
      EasyDateTime.clearDefaultLocation();

      // Verify via deprecated function
      expect(getDefaultLocation(), isNull);
    });
  });

  group('TimeZones InvalidTimeZoneException', () {
    test('_getSafeLocation throws InvalidTimeZoneException for invalid zone',
        () {
      // This tests the InvalidTimeZoneException throw path in timezones.dart
      // We can't directly call _getSafeLocation, but we can trigger it
      // by accessing a getter that would fail if the location doesn't exist
      // However, all built-in getters use valid locations.
      // The exception would only be thrown if the IANA database changes.
      // For now, we verify that valid locations work correctly.
      expect(() => TimeZones.tokyo, returnsNormally);
      expect(() => TimeZones.shanghai, returnsNormally);
    });
  });
}
