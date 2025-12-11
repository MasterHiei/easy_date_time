import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart';

// Will be set in setUpAll after timezone initialization
late Location localTimeZone;

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
    // Get local timezone reference after initialization
    localTimeZone = local;
  });

  tearDown(() {
    // Reset global default after each test to local timezone
    EasyDateTime.clearDefaultLocation();
  });

  group('EasyDateTime', () {
    group('constructors', () {
      test('creates with date components using default timezone', () {
        final dt = EasyDateTime(2025, 12, 1, 10, 30, 45);

        expect(dt.year, 2025);
        expect(dt.month, 12);
        expect(dt.day, 1);
        expect(dt.hour, 10);
        expect(dt.minute, 30);
        expect(dt.second, 45);
        // Default is local timezone
        expect(dt.location, localTimeZone);
      });

      test('creates with explicit location', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 12, 1, 10, 30, 45, 0, 0, tokyo);

        expect(dt.locationName, 'Asia/Tokyo');
      });

      test('now() creates current time using default timezone', () {
        // Note: We don't test the day here because EasyDateTime.now() depends on
        // the timezone library's initialization, which can be affected by global state
        final dt = EasyDateTime.now();

        // Verify that year, month, and date components exist and are reasonable
        expect(dt.year, greaterThan(2020));
        expect(dt.month, greaterThanOrEqualTo(1));
        expect(dt.month, lessThanOrEqualTo(12));
        expect(dt.day, greaterThanOrEqualTo(1));
        expect(dt.day, lessThanOrEqualTo(31));
      });

      test('now() with location creates current time in specified timezone',
          () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime.now(location: tokyo);

        expect(dt.locationName, 'Asia/Tokyo');
      });

      test('utc() creates UTC datetime', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 12, 0);

        expect(dt.year, 2025);
        expect(dt.month, 6);
        expect(dt.hour, 12);
        expect(dt.locationName, 'UTC');
      });

      test('fromDateTime() converts DateTime to default timezone', () {
        final utcDt = DateTime.utc(2025, 12, 1, 0, 0);
        final easyDt = EasyDateTime.fromDateTime(utcDt);

        // Converts to local timezone
        expect(easyDt.location, localTimeZone);
        expect(easyDt.millisecondsSinceEpoch, utcDt.millisecondsSinceEpoch);
      });

      test('fromDateTime() converts DateTime to specified timezone', () {
        final utcDt = DateTime.utc(2025, 12, 1, 0, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final easyDt = EasyDateTime.fromDateTime(utcDt, location: tokyo);

        // UTC 0:00 -> Tokyo 9:00 (same day)
        expect(easyDt.hour, 9);
        expect(easyDt.day, 1);
        expect(easyDt.locationName, 'Asia/Tokyo');
      });

      test('fromMillisecondsSinceEpoch() creates from timestamp', () {
        final timestamp = DateTime.utc(2025, 1, 1).millisecondsSinceEpoch;
        final dt = EasyDateTime.fromMillisecondsSinceEpoch(timestamp);

        expect(dt.year, 2025);
        expect(dt.month, 1);
        expect(dt.day, 1);
      });

      test('parse() parses ISO 8601 string', () {
        final dt = EasyDateTime.parse('2025-12-01T10:30:00Z');

        expect(dt.year, 2025);
        expect(dt.month, 12);
        expect(dt.day, 1);
        expect(dt.hour, 10);
        expect(dt.minute, 30);
      });

      test('tryParse() returns null for invalid string', () {
        final result = EasyDateTime.tryParse('invalid');
        expect(result, isNull);
      });

      test('tryParse() succeeds for valid string', () {
        final result = EasyDateTime.tryParse('2025-12-01T12:00:00Z');
        expect(result, isNotNull);
        expect(result!.year, 2025);
      });
    });

    group('global default timezone', () {
      test('setDefaultLocation changes default timezone', () {
        EasyDateTime.setDefaultLocation(getLocation('Asia/Tokyo'));

        final dt = EasyDateTime(2025, 12, 1, 10, 30);
        expect(dt.locationName, 'Asia/Tokyo');
      });

      test('clearDefaultLocation resets to local', () {
        EasyDateTime.setDefaultLocation(getLocation('Asia/Tokyo'));
        EasyDateTime.clearDefaultLocation();

        final dt = EasyDateTime(2025, 12, 1, 10, 30);
        expect(dt.location, localTimeZone);
      });

      test('getDefaultLocation returns current default', () {
        expect(EasyDateTime.getDefaultLocation(), isNull);

        final tokyo = getLocation('Asia/Tokyo');
        EasyDateTime.setDefaultLocation(tokyo);
        expect(EasyDateTime.getDefaultLocation(), tokyo);
      });

      test('now() uses global default', () {
        EasyDateTime.setDefaultLocation(getLocation('America/New_York'));
        final dt = EasyDateTime.now();
        expect(dt.locationName, 'America/New_York');
      });

      test('explicit location overrides global default', () {
        EasyDateTime.setDefaultLocation(getLocation('Asia/Tokyo'));
        final london = getLocation('Europe/London');
        final dt = EasyDateTime.now(location: london);
        expect(dt.locationName, 'Europe/London');
      });
    });

    group('properties', () {
      test('weekday returns correct day of week', () {
        // 2025-12-01 is Monday
        final dt = EasyDateTime.utc(2025, 12, 1);
        expect(dt.weekday, DateTime.monday);
      });

      test('millisecondsSinceEpoch returns correct value', () {
        final dt = EasyDateTime.utc(1970, 1, 1, 0, 0, 0);
        expect(dt.millisecondsSinceEpoch, 0);
      });

      test('timeZoneOffset returns correct offset', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 12, 15, 0, 0, 0, 0, 0, tokyo);
        // Tokyo is UTC+9 (no DST)
        expect(dt.timeZoneOffset, const Duration(hours: 9));
      });
    });

    group('timezone conversion', () {
      test('inLocation() converts to different timezone', () {
        final tokyo = getLocation('Asia/Tokyo');
        final newYork = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 12, 1, 12, 0, 0, 0, 0, tokyo);

        final nyDt = dt.inLocation(newYork);

        // Same moment in time, different display
        expect(nyDt.millisecondsSinceEpoch, dt.millisecondsSinceEpoch);
        expect(nyDt.locationName, 'America/New_York');
        // Tokyo 12:00 (Dec 1) is New York 22:00 (Nov 30)
        expect(nyDt.hour, 22);
        expect(nyDt.day, 30);
      });

      test('toUtc() converts to UTC', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 12, 1, 9, 0, 0, 0, 0, tokyo);
        final utc = dt.toUtc();

        expect(utc.locationName, 'UTC');
        expect(utc.hour, 0);
        expect(utc.day, 1);
      });

      test('toDateTime() returns standard DateTime', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 12, 1, 10, 30, 0, 0, 0, tokyo);
        final stdDt = dt.toDateTime();

        expect(stdDt, isA<DateTime>());
        expect(stdDt.year, 2025);
        expect(stdDt.month, 12);
        expect(stdDt.day, 1);
      });
    });

    group('arithmetic operations', () {
      test('add() adds duration', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 0);
        final result = dt.add(const Duration(hours: 2));

        expect(result.hour, 12);
      });

      test('subtract() subtracts duration', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 0);
        final result = dt.subtract(const Duration(days: 1));

        expect(result.day, 30);
      });

      test('difference() calculates duration between times', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 0);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 12, 0);

        expect(dt2.difference(dt1), const Duration(hours: 2));
      });
    });

    group('operators', () {
      test('+ adds duration', () {
        final dt = EasyDateTime.utc(2025, 12, 1);
        final result = dt + const Duration(days: 1);

        expect(result.day, 2); // Dec 2
      });

      test('- subtracts duration', () {
        final dt = EasyDateTime.utc(2025, 12, 1);
        final result = dt - const Duration(days: 1);

        expect(result.day, 30); // Nov 30
      });

      test('< compares correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1 < dt2, true);
        expect(dt2 < dt1, false);
      });

      test('> compares correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1 > dt2, true);
        expect(dt2 > dt1, false);
      });

      test('<= compares correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        final dt3 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1 <= dt2, true);
        expect(dt1 <= dt3, true);
        expect(dt3 <= dt1, false);
      });

      test('>= compares correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        final dt3 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1 >= dt2, true);
        expect(dt1 >= dt3, true);
        expect(dt2 >= dt1, false);
      });

      test('== compares same moment and timezone', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1 == dt2, true);
      });

      test('== returns true for same moment in different timezones', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 9, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final dt2 = EasyDateTime(2025, 12, 1, 18, 0, 0, 0, 0, tokyo);

        // Same moment in time, different timezone - should be equal
        expect(dt1.isAtSameMomentAs(dt2), true);
        expect(dt1 == dt2, true);
      });
    });

    group('comparison methods', () {
      test('isBefore() checks if before', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1.isBefore(dt2), true);
        expect(dt2.isBefore(dt1), false);
      });

      test('isAfter() checks if after', () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1.isAfter(dt2), true);
        expect(dt2.isAfter(dt1), false);
      });

      test('isAtSameMomentAs() ignores timezone difference', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 0, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final dt2 = EasyDateTime(2025, 12, 1, 9, 0, 0, 0, 0, tokyo);

        expect(dt1.isAtSameMomentAs(dt2), true);
      });

      test('compareTo() returns correct ordering', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);
        final dt3 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1.compareTo(dt2) < 0, true);
        expect(dt2.compareTo(dt1) > 0, true);
        expect(dt1.compareTo(dt3), 0);
      });
    });

    group('formatting', () {
      test('toIso8601String() returns ISO format', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30, 45);
        final result = dt.toIso8601String();

        expect(result, contains('2025-12-01'));
        expect(result, contains('10:30:45'));
      });

      test('toString() returns readable string', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final result = dt.toString();

        expect(result, contains('2025-12-01'));
        expect(result, contains('10:30'));
      });
    });

    group('JSON serialization', () {
      test('toJson() returns ISO 8601 string', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 12, 1, 10, 30, 0, 0, 0, tokyo);
        final json = dt.toIso8601String();

        expect(json, isA<String>());
        expect(json, contains('2025-12-01'));
        expect(json, contains('10:30'));
      });

      test('fromJson() parses ISO 8601 string', () {
        final json = '2025-12-01T10:30:00.000+09:00';
        final dt = EasyDateTime.fromIso8601String(json);

        expect(dt.year, 2025);
        expect(dt.month, 12);
        expect(dt.day, 1);
      });

      test('JSON round-trip preserves moment', () {
        final tokyo = getLocation('Asia/Tokyo');
        final original = EasyDateTime(2025, 12, 15, 14, 30, 45, 123, 0, tokyo);
        final json = original.toIso8601String();
        final restored = EasyDateTime.fromIso8601String(json);

        expect(
          restored.millisecondsSinceEpoch,
          original.millisecondsSinceEpoch,
        );
      });
    });

    group('copyWith', () {
      test('copies with modified fields', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final modified = dt.copyWith(year: 2026, month: 6);

        expect(modified.year, 2026);
        expect(modified.month, 6);
        expect(modified.day, 1);
        expect(modified.hour, 10);
      });

      test('copies with new location', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final tokyo = getLocation('Asia/Tokyo');
        final modified = dt.copyWith(location: tokyo);

        expect(modified.locationName, 'Asia/Tokyo');
        expect(modified.hour, 10);
      });
    });

    group('edge cases', () {
      test('handles leap year correctly', () {
        final dt = EasyDateTime.utc(2024, 2, 29); // 2024 is a leap year
        expect(dt.day, 29);
        expect(dt.month, 2);
      });

      test('handles end of month correctly', () {
        final dt = EasyDateTime.utc(2025, 1, 31);
        final nextDay = dt + const Duration(days: 1);

        expect(nextDay.month, 2);
        expect(nextDay.day, 1);
      });

      test('handles year boundary correctly', () {
        final dt = EasyDateTime.utc(2025, 12, 31, 23, 59, 59);
        final nextSecond = dt + const Duration(seconds: 1);

        expect(nextSecond.year, 2026);
        expect(nextSecond.month, 1);
        expect(nextSecond.day, 1);
      });
    });
  });

  group('DurationExtension', () {
    test('weeks creates correct duration', () {
      expect(1.weeks, const Duration(days: 7));
      expect(2.weeks, const Duration(days: 14));
    });

    test('days creates correct duration', () {
      expect(1.days, const Duration(days: 1));
      expect(5.days, const Duration(days: 5));
    });

    test('hours creates correct duration', () {
      expect(1.hours, const Duration(hours: 1));
      expect(24.hours, const Duration(hours: 24));
    });

    test('minutes creates correct duration', () {
      expect(1.minutes, const Duration(minutes: 1));
      expect(60.minutes, const Duration(minutes: 60));
    });

    test('seconds creates correct duration', () {
      expect(1.seconds, const Duration(seconds: 1));
      expect(60.seconds, const Duration(seconds: 60));
    });

    test('milliseconds creates correct duration', () {
      expect(1.milliseconds, const Duration(milliseconds: 1));
      expect(1000.milliseconds, const Duration(milliseconds: 1000));
    });

    test('microseconds creates correct duration', () {
      expect(1.microseconds, const Duration(microseconds: 1));
      expect(1000.microseconds, const Duration(microseconds: 1000));
    });

    test('can combine multiple durations', () {
      final combined = 1.days + 2.hours + 30.minutes;
      expect(
        combined,
        const Duration(days: 1, hours: 2, minutes: 30),
      );
    });
  });

  group('DateTimeExtension', () {
    test('toEasyDateTime() uses default timezone', () {
      final dt = DateTime.utc(2025, 12, 1, 10, 30);
      final easyDt = dt.toEasyDateTime();

      expect(easyDt.location, localTimeZone);
      expect(easyDt.millisecondsSinceEpoch, dt.millisecondsSinceEpoch);
    });

    test('toEasyDateTime() converts with location', () {
      final dt = DateTime.utc(2025, 12, 1, 10, 30);
      final tokyo = getLocation('Asia/Tokyo');
      final easyDt = dt.toEasyDateTime(location: tokyo);

      expect(easyDt.locationName, 'Asia/Tokyo');
      expect(easyDt.millisecondsSinceEpoch, dt.millisecondsSinceEpoch);
    });

    test('toEasyDateTime() uses global default', () {
      EasyDateTime.setDefaultLocation(getLocation('Europe/London'));
      final dt = DateTime.utc(2025, 12, 1, 10, 30);
      final easyDt = dt.toEasyDateTime();

      expect(easyDt.locationName, 'Europe/London');
      EasyDateTime.clearDefaultLocation(); // Clean up
    });
  });
}
