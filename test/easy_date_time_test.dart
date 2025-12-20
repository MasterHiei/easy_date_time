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

      test('timestamp() returns current UTC time', () {
        final before = DateTime.now().toUtc().millisecondsSinceEpoch;
        final dt = EasyDateTime.timestamp();
        final after = DateTime.now().toUtc().millisecondsSinceEpoch;

        expect(dt.locationName, 'UTC');
        expect(dt.timeZoneOffset, Duration.zero);
        expect(dt.millisecondsSinceEpoch, greaterThanOrEqualTo(before));
        expect(dt.millisecondsSinceEpoch, lessThanOrEqualTo(after));
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

      test('fromMillisecondsSinceEpoch() with isUtc=true returns UTC', () {
        final timestamp =
            DateTime.utc(2025, 6, 15, 12, 0).millisecondsSinceEpoch;
        final dt = EasyDateTime.fromMillisecondsSinceEpoch(
          timestamp,
          isUtc: true,
        );

        expect(dt.locationName, 'UTC');
        expect(dt.year, 2025);
        expect(dt.month, 6);
        expect(dt.day, 15);
        expect(dt.hour, 12);
      });

      test('fromMillisecondsSinceEpoch() with explicit location', () {
        final timestamp =
            DateTime.utc(2025, 6, 15, 12, 0).millisecondsSinceEpoch;
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime.fromMillisecondsSinceEpoch(
          timestamp,
          location: tokyo,
        );

        expect(dt.locationName, 'Asia/Tokyo');
        // UTC 12:00 = Tokyo 21:00 (UTC+9)
        expect(dt.hour, 21);
      });

      test(
          'fromMillisecondsSinceEpoch() throws when isUtc and location both set',
          () {
        expect(
          () => EasyDateTime.fromMillisecondsSinceEpoch(
            1000,
            isUtc: true,
            location: TimeZones.tokyo,
          ),
          throwsArgumentError,
        );
      });

      test('fromSecondsSinceEpoch() creates from seconds timestamp', () {
        // 2025-01-01 00:00:00 UTC = 1735689600 seconds
        final dt = EasyDateTime.fromSecondsSinceEpoch(
          1735689600,
          location: TimeZones.utc,
        );
        expect(dt.year, 2025);
        expect(dt.month, 1);
        expect(dt.day, 1);
        expect(dt.hour, 0);
        expect(dt.minute, 0);
        expect(dt.second, 0);
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

      test('timeZoneName returns valid name expression', () {
        final dt = EasyDateTime.now(location: TimeZones.newYork);
        // EST or EDT depending on time, but just checking it returns a string
        expect(dt.timeZoneName, isNotEmpty);
        expect(dt.timeZoneName, anyOf('EST', 'EDT', 'GMT-5', 'GMT-4'));
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

      test('== returns false for same moment in different timezones', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 9, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final dt2 = EasyDateTime(2025, 12, 1, 18, 0, 0, 0, 0, tokyo);

        // Same moment in time, but different timezone - not equal (DateTime-compatible)
        expect(dt1.isAtSameMomentAs(dt2), true);
        expect(dt1 == dt2, false);
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

    group('Constructors', () {
      test('fromMicrosecondsSinceEpoch creates from microseconds timestamp',
          () {
        final timestamp = DateTime.utc(2025, 1, 1).microsecondsSinceEpoch;
        final dt = EasyDateTime.fromMicrosecondsSinceEpoch(timestamp);

        expect(dt.year, 2025);
        expect(dt.month, 1);
        expect(dt.day, 1);
      });

      test('fromMicrosecondsSinceEpoch with explicit location', () {
        final timestamp =
            DateTime.utc(2025, 6, 15, 12, 0).microsecondsSinceEpoch;
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime.fromMicrosecondsSinceEpoch(
          timestamp,
          location: tokyo,
        );

        expect(dt.locationName, 'Asia/Tokyo');
        expect(dt.hour, 21); // 12 UTC = 21 Tokyo
      });

      test('fromMicrosecondsSinceEpoch() with isUtc=true returns UTC', () {
        final timestamp =
            DateTime.utc(2025, 6, 15, 12, 0).microsecondsSinceEpoch;
        final dt = EasyDateTime.fromMicrosecondsSinceEpoch(
          timestamp,
          isUtc: true,
        );

        expect(dt.locationName, 'UTC');
        expect(dt.year, 2025);
        expect(dt.month, 6);
        expect(dt.day, 15);
        expect(dt.hour, 12);
      });

      test(
          'fromMicrosecondsSinceEpoch() throws when isUtc and location both set',
          () {
        expect(
          () => EasyDateTime.fromMicrosecondsSinceEpoch(
            1000,
            isUtc: true,
            location: TimeZones.tokyo,
          ),
          throwsArgumentError,
        );
      });

      test('fromSecondsSinceEpoch() with isUtc=true returns UTC', () {
        // 2025-06-15 12:00:00 UTC
        final seconds =
            DateTime.utc(2025, 6, 15, 12, 0).millisecondsSinceEpoch ~/ 1000;
        final dt = EasyDateTime.fromSecondsSinceEpoch(seconds, isUtc: true);

        expect(dt.locationName, 'UTC');
        expect(dt.year, 2025);
        expect(dt.month, 6);
        expect(dt.day, 15);
        expect(dt.hour, 12);
      });

      test('fromSecondsSinceEpoch() throws when isUtc and location both set',
          () {
        expect(
          () => EasyDateTime.fromSecondsSinceEpoch(
            1000,
            isUtc: true,
            location: TimeZones.tokyo,
          ),
          throwsArgumentError,
        );
      });
    });

    group('Conversion', () {
      test('toLocal converts to system local timezone', () {
        final utc = EasyDateTime.utc(2025, 12, 1, 12, 0);
        final local = utc.toLocal();

        // Same moment, but in local timezone
        expect(local.millisecondsSinceEpoch, utc.millisecondsSinceEpoch);
      });
    });

    group('Equality and HashCode', () {
      test('hashCode is consistent', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        expect(dt1.hashCode, dt2.hashCode);
      });

      test('different datetime has different hashCode', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 31);
        expect(dt1.hashCode, isNot(dt2.hashCode));
      });

      test('UTC and non-UTC have different hashCode even for same moment', () {
        // Same moment: UTC 02:30 = Shanghai 10:30 (+8)
        final utc = EasyDateTime.utc(2025, 12, 1, 2, 30);
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        // Same moment but different isUtc -> different hashCode
        expect(utc.isAtSameMomentAs(shanghai), isTrue);
        expect(utc.hashCode, isNot(shanghai.hashCode));
      });

      test('same moment in same isUtc has same hashCode', () {
        // 10:30 Shanghai (+8) = 11:30 Tokyo (+9), both non-UTC
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final tokyo = EasyDateTime.parse('2025-12-01T11:30:00+09:00');
        // Same moment, both non-UTC -> same hashCode
        expect(shanghai.hashCode, tokyo.hashCode);
      });

      test('equality (==) checks moment equality', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        expect(dt1 == dt2, isTrue);
      });

      test('UTC vs non-UTC are NOT equal even for same moment', () {
        final utc = EasyDateTime.utc(2025, 12, 1, 2, 30);
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        // Same moment but different isUtc -> not equal
        expect(utc.isAtSameMomentAs(shanghai), isTrue);
        expect(utc == shanghai, isFalse);
      });

      test('same moment with same isUtc are equal', () {
        // 10:30 Shanghai (+8) = 11:30 Tokyo (+9), both non-UTC = same isUtc
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final tokyo = EasyDateTime.parse('2025-12-01T11:30:00+09:00');
        // Same moment, both non-UTC -> equal (DateTime-compatible)
        expect(shanghai.isAtSameMomentAs(tokyo), isTrue);
        expect(shanghai == tokyo, isTrue);
      });

      test('different moments are not equal', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 31);
        expect(dt1 == dt2, isFalse);
      });

      test('stores UTC and non-UTC as distinct entries in Set', () {
        final utc = EasyDateTime.utc(2025, 12, 1, 2, 30);
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final set = <EasyDateTime>{utc, shanghai};
        // Same moment but different isUtc -> separate entries
        expect(set.length, 2);
      });

      test('deduplicates same moment with same isUtc in Set', () {
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final tokyo = EasyDateTime.parse('2025-12-01T11:30:00+09:00');
        final set = <EasyDateTime>{shanghai, tokyo};
        // Same moment, both non-UTC -> deduplicated to 1
        expect(set.length, 1);
      });
    });

    group('copyWithClamped', () {
      test('clamps day to month end', () {
        final jan31 = EasyDateTime.utc(2025, 1, 31);
        final feb = jan31.copyWithClamped(month: 2);
        expect(feb.day, 28);
      });

      test('clamps to leap year Feb 29', () {
        final jan31 = EasyDateTime.utc(2024, 1, 31);
        final feb = jan31.copyWithClamped(month: 2);
        expect(feb.day, 29);
      });

      test('clamps to 30-day month', () {
        final jan31 = EasyDateTime.utc(2025, 1, 31);
        final apr = jan31.copyWithClamped(month: 4);
        expect(apr.day, 30);
      });

      test('does not clamp valid days', () {
        final jan15 = EasyDateTime.utc(2025, 1, 15);
        final feb = jan15.copyWithClamped(month: 2);
        expect(feb.day, 15);
      });

      test('preserves time components and location', () {
        final tokyo = EasyDateTime(
          2025,
          1,
          31,
          10,
          30,
          45,
          123,
          456,
          TimeZones.tokyo,
        );
        final feb = tokyo.copyWithClamped(month: 2);

        expect(feb.locationName, 'Asia/Tokyo');
        expect(feb.hour, 10);
        expect(feb.minute, 30);
        expect(feb.second, 45);
        expect(feb.millisecond, 123);
        expect(feb.microsecond, 456);
      });
    });

    group('startOf', () {
      test('startOf(year) returns first moment of year', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45, 123, 456);
        final start = dt.startOf(DateTimeUnit.year);
        expect(start.year, 2025);
        expect(start.month, 1);
        expect(start.day, 1);
        expect(start.hour, 0);
        expect(start.minute, 0);
        expect(start.second, 0);
        expect(start.millisecond, 0);
        expect(start.microsecond, 0);
      });

      test('startOf(month) returns first moment of month', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45);
        final start = dt.startOf(DateTimeUnit.month);
        expect(start.month, 6);
        expect(start.day, 1);
        expect(start.hour, 0);
      });

      test('startOf(day) returns midnight', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45);
        final start = dt.startOf(DateTimeUnit.day);
        expect(start.day, 15);
        expect(start.hour, 0);
        expect(start.minute, 0);
      });

      test('startOf(hour) truncates to start of current hour', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45, 123, 456);
        final start = dt.startOf(DateTimeUnit.hour);
        expect(start.hour, 14);
        expect(start.minute, 0);
        expect(start.second, 0);
        expect(start.millisecond, 0);
        expect(start.microsecond, 0);
      });

      test('startOf(minute) truncates to start of current minute', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45, 123, 456);
        final start = dt.startOf(DateTimeUnit.minute);
        expect(start.minute, 30);
        expect(start.second, 0);
        expect(start.millisecond, 0);
        expect(start.microsecond, 0);
      });

      test('startOf(second) truncates to start of current second', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45, 123, 456);
        final start = dt.startOf(DateTimeUnit.second);
        expect(start.second, 45);
        expect(start.millisecond, 0);
        expect(start.microsecond, 0);
      });

      test('startOf preserves location', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30, 0, 0, 0, TimeZones.tokyo);
        final start = dt.startOf(DateTimeUnit.day);
        expect(start.locationName, 'Asia/Tokyo');
      });
    });

    group('endOf', () {
      test('endOf(year) returns last moment of year', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45);
        final end = dt.endOf(DateTimeUnit.year);
        expect(end.year, 2025);
        expect(end.month, 12);
        expect(end.day, 31);
        expect(end.hour, 23);
        expect(end.minute, 59);
        expect(end.second, 59);
        expect(end.millisecond, 999);
        expect(end.microsecond, 999);
      });

      test('endOf(month) returns last moment of month', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45);
        final end = dt.endOf(DateTimeUnit.month);
        expect(end.month, 6);
        expect(end.day, 30); // June has 30 days
        expect(end.hour, 23);
        expect(end.minute, 59);
      });

      test('endOf(day) returns end of day', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45);
        final end = dt.endOf(DateTimeUnit.day);
        expect(end.day, 15);
        expect(end.hour, 23);
        expect(end.minute, 59);
        expect(end.second, 59);
      });

      test('endOf preserves location', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30, 0, 0, 0, TimeZones.tokyo);
        final end = dt.endOf(DateTimeUnit.day);
        expect(end.locationName, 'Asia/Tokyo');
      });

      test('endOf(hour) extends to last moment of current hour', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45);
        final end = dt.endOf(DateTimeUnit.hour);
        expect(end.hour, 14);
        expect(end.minute, 59);
        expect(end.second, 59);
        expect(end.millisecond, 999);
        expect(end.microsecond, 999);
      });

      test('endOf(minute) extends to last moment of current minute', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45);
        final end = dt.endOf(DateTimeUnit.minute);
        expect(end.minute, 30);
        expect(end.second, 59);
        expect(end.millisecond, 999);
        expect(end.microsecond, 999);
      });

      test('endOf(second) extends to last moment of current second', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 14, 30, 45, 123, 456);
        final end = dt.endOf(DateTimeUnit.second);
        expect(end.second, 45);
        expect(end.millisecond, 999);
        expect(end.microsecond, 999);
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
