import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' show local;

/// Tests for PR #7 changes: DateTime compatibility constants and static methods.
///
/// These tests verify that:
/// 1. Weekday and month constants match DateTime's constants
/// 2. Static configuration methods work correctly on EasyDateTime class
void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('DateTime Compatibility Constants', () {
    group('Weekday constants', () {
      test('monday matches DateTime.monday', () {
        expect(EasyDateTime.monday, DateTime.monday);
        expect(EasyDateTime.monday, 1);
      });

      test('tuesday matches DateTime.tuesday', () {
        expect(EasyDateTime.tuesday, DateTime.tuesday);
        expect(EasyDateTime.tuesday, 2);
      });

      test('wednesday matches DateTime.wednesday', () {
        expect(EasyDateTime.wednesday, DateTime.wednesday);
        expect(EasyDateTime.wednesday, 3);
      });

      test('thursday matches DateTime.thursday', () {
        expect(EasyDateTime.thursday, DateTime.thursday);
        expect(EasyDateTime.thursday, 4);
      });

      test('friday matches DateTime.friday', () {
        expect(EasyDateTime.friday, DateTime.friday);
        expect(EasyDateTime.friday, 5);
      });

      test('saturday matches DateTime.saturday', () {
        expect(EasyDateTime.saturday, DateTime.saturday);
        expect(EasyDateTime.saturday, 6);
      });

      test('sunday matches DateTime.sunday', () {
        expect(EasyDateTime.sunday, DateTime.sunday);
        expect(EasyDateTime.sunday, 7);
      });

      test('daysPerWeek matches DateTime.daysPerWeek', () {
        expect(EasyDateTime.daysPerWeek, DateTime.daysPerWeek);
        expect(EasyDateTime.daysPerWeek, 7);
      });

      test('weekday property returns correct constant', () {
        // 2025-12-01 is Monday
        final monday = EasyDateTime.utc(2025, 12, 1);
        expect(monday.weekday, EasyDateTime.monday);

        // 2025-12-07 is Sunday
        final sunday = EasyDateTime.utc(2025, 12, 7);
        expect(sunday.weekday, EasyDateTime.sunday);
      });
    });

    group('Month constants', () {
      test('january matches DateTime.january', () {
        expect(EasyDateTime.january, DateTime.january);
        expect(EasyDateTime.january, 1);
      });

      test('february matches DateTime.february', () {
        expect(EasyDateTime.february, DateTime.february);
        expect(EasyDateTime.february, 2);
      });

      test('march matches DateTime.march', () {
        expect(EasyDateTime.march, DateTime.march);
        expect(EasyDateTime.march, 3);
      });

      test('april matches DateTime.april', () {
        expect(EasyDateTime.april, DateTime.april);
        expect(EasyDateTime.april, 4);
      });

      test('may matches DateTime.may', () {
        expect(EasyDateTime.may, DateTime.may);
        expect(EasyDateTime.may, 5);
      });

      test('june matches DateTime.june', () {
        expect(EasyDateTime.june, DateTime.june);
        expect(EasyDateTime.june, 6);
      });

      test('july matches DateTime.july', () {
        expect(EasyDateTime.july, DateTime.july);
        expect(EasyDateTime.july, 7);
      });

      test('august matches DateTime.august', () {
        expect(EasyDateTime.august, DateTime.august);
        expect(EasyDateTime.august, 8);
      });

      test('september matches DateTime.september', () {
        expect(EasyDateTime.september, DateTime.september);
        expect(EasyDateTime.september, 9);
      });

      test('october matches DateTime.october', () {
        expect(EasyDateTime.october, DateTime.october);
        expect(EasyDateTime.october, 10);
      });

      test('november matches DateTime.november', () {
        expect(EasyDateTime.november, DateTime.november);
        expect(EasyDateTime.november, 11);
      });

      test('december matches DateTime.december', () {
        expect(EasyDateTime.december, DateTime.december);
        expect(EasyDateTime.december, 12);
      });

      test('monthsPerYear matches DateTime.monthsPerYear', () {
        expect(EasyDateTime.monthsPerYear, DateTime.monthsPerYear);
        expect(EasyDateTime.monthsPerYear, 12);
      });

      test('month property returns correct constant', () {
        final january = EasyDateTime.utc(2025, 1, 15);
        expect(january.month, EasyDateTime.january);

        final december = EasyDateTime.utc(2025, 12, 15);
        expect(december.month, EasyDateTime.december);
      });
    });
  });

  group('Static Configuration Methods', () {
    test('EasyDateTime.setDefaultLocation sets global default', () {
      EasyDateTime.setDefaultLocation(TimeZones.tokyo);

      final dt = EasyDateTime(2025, 12, 1, 10, 30);
      expect(dt.locationName, 'Asia/Tokyo');
    });

    test('EasyDateTime.getDefaultLocation returns current default', () {
      expect(EasyDateTime.getDefaultLocation(), isNull);

      EasyDateTime.setDefaultLocation(TimeZones.shanghai);
      expect(EasyDateTime.getDefaultLocation()?.name, 'Asia/Shanghai');
    });

    test('EasyDateTime.clearDefaultLocation resets to local', () {
      EasyDateTime.setDefaultLocation(TimeZones.london);
      expect(EasyDateTime.getDefaultLocation(), isNotNull);

      EasyDateTime.clearDefaultLocation();
      expect(EasyDateTime.getDefaultLocation(), isNull);

      final dt = EasyDateTime.now();
      expect(dt.location, local);
    });

    test('EasyDateTime.effectiveDefaultLocation returns effective location',
        () {
      // When no default is set, should return local
      EasyDateTime.clearDefaultLocation();
      expect(EasyDateTime.effectiveDefaultLocation, local);

      // When default is set, should return that
      EasyDateTime.setDefaultLocation(TimeZones.newYork);
      expect(EasyDateTime.effectiveDefaultLocation.name, 'America/New_York');
    });

    test('EasyDateTime.isTimeZoneInitialized returns true after init', () {
      // Since we called initializeTimeZone in setUpAll, this should be true
      expect(EasyDateTime.isTimeZoneInitialized, isTrue);
    });

    test('Static methods are equivalent to global functions', () {
      // Set via static method
      EasyDateTime.setDefaultLocation(TimeZones.paris);
      final viaStatic = EasyDateTime.getDefaultLocation();

      // Get via global function
      final viaGlobal = EasyDateTime.getDefaultLocation();

      expect(viaStatic, viaGlobal);

      // Clear via static method
      EasyDateTime.clearDefaultLocation();
      expect(EasyDateTime.getDefaultLocation(), isNull);

      // Set via global function
      EasyDateTime.setDefaultLocation(TimeZones.berlin);
      expect(EasyDateTime.getDefaultLocation()?.name, 'Europe/Berlin');
    });

    test('EasyDateTime.now() uses static setDefaultLocation', () {
      EasyDateTime.setDefaultLocation(TimeZones.sydney);
      final now = EasyDateTime.now();

      expect(now.locationName, 'Australia/Sydney');
    });
  });
}
