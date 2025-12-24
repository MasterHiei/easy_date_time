import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

// Will be set in setUpAll after timezone initialization
late Location localTimeZone;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
    // Get local timezone reference after initialization
    localTimeZone = local;
  });

  tearDown(() {
    // Reset global default after each test to local timezone
    EasyDateTime.clearDefaultLocation();
  });

  group('EasyDateTime Core', () {
    group('Constructors', () {
      test('EasyDateTime(y, m, d...) uses default location (local if unset)',
          () {
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

      test('EasyDateTime(..., location: loc) uses specified timezone', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 12, 1, 10, 30, 45, 0, 0, tokyo);

        expect(dt.locationName, 'Asia/Tokyo');
      });

      test('now() captures current time in default location', () {
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

      test('now(location: loc) captures current time in specified timezone',
          () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime.now(location: tokyo);

        expect(dt.locationName, 'Asia/Tokyo');
      });

      test('utc() creates UTC instance', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 12, 0);

        expect(dt.year, 2025);
        expect(dt.month, 6);
        expect(dt.hour, 12);
        expect(dt.locationName, 'UTC');
      });

      test('timestamp() returns current time in UTC', () {
        final before = DateTime.now().toUtc().millisecondsSinceEpoch;
        final dt = EasyDateTime.timestamp();
        final after = DateTime.now().toUtc().millisecondsSinceEpoch;

        expect(dt.locationName, 'UTC');
        expect(dt.timeZoneOffset, Duration.zero);
        expect(dt.millisecondsSinceEpoch, greaterThanOrEqualTo(before));
        expect(dt.millisecondsSinceEpoch, lessThanOrEqualTo(after));
      });

      test('fromDateTime() adapts DateTime to default location', () {
        final utcDt = DateTime.utc(2025, 12, 1, 0, 0);
        final easyDt = EasyDateTime.fromDateTime(utcDt);

        // Converts to local timezone
        expect(easyDt.location, localTimeZone);
        expect(easyDt.millisecondsSinceEpoch, utcDt.millisecondsSinceEpoch);
      });

      test('fromDateTime() adapts DateTime to specified location', () {
        final utcDt = DateTime.utc(2025, 12, 1, 0, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final easyDt = EasyDateTime.fromDateTime(utcDt, location: tokyo);

        // UTC 0:00 -> Tokyo 9:00 (same day)
        expect(easyDt.hour, 9);
        expect(easyDt.day, 1);
        expect(easyDt.locationName, 'Asia/Tokyo');
      });

      test('fromMillisecondsSinceEpoch() creates instance from timestamp', () {
        final timestamp = DateTime.utc(2025, 1, 1).millisecondsSinceEpoch;
        final dt = EasyDateTime.fromMillisecondsSinceEpoch(timestamp);

        expect(dt.year, 2025);
        expect(dt.month, 1);
        expect(dt.day, 1);
      });

      test('fromMillisecondsSinceEpoch(..., isUtc: true) returns UTC instance',
          () {
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

      test(
          'fromMillisecondsSinceEpoch() converts timestamp to specified location',
          () {
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

      test('fromMillisecondsSinceEpoch() throws if isUtc and location both set',
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

    group('Global Default Timezone', () {
      test('setDefaultLocation(loc) sets global default timezone', () {
        EasyDateTime.setDefaultLocation(getLocation('Asia/Tokyo'));

        final dt = EasyDateTime(2025, 12, 1, 10, 30);
        expect(dt.locationName, 'Asia/Tokyo');
      });

      test('clearDefaultLocation() resets global default to local', () {
        EasyDateTime.setDefaultLocation(getLocation('Asia/Tokyo'));
        EasyDateTime.clearDefaultLocation();

        final dt = EasyDateTime(2025, 12, 1, 10, 30);
        expect(dt.location, localTimeZone);
      });

      test('getDefaultLocation() returns current global default or null', () {
        expect(EasyDateTime.getDefaultLocation(), isNull);

        final tokyo = getLocation('Asia/Tokyo');
        EasyDateTime.setDefaultLocation(tokyo);
        expect(EasyDateTime.getDefaultLocation(), tokyo);
      });

      test('now() uses global default location if unspecified', () {
        EasyDateTime.setDefaultLocation(getLocation('America/New_York'));
        final dt = EasyDateTime.now();
        expect(dt.locationName, 'America/New_York');
      });

      test('explicit location parameter overrides global default', () {
        EasyDateTime.setDefaultLocation(getLocation('Asia/Tokyo'));
        final london = getLocation('Europe/London');
        final dt = EasyDateTime.now(location: london);
        expect(dt.locationName, 'Europe/London');
      });
    });

    group('Properties', () {
      test('weekday returns standard Dart constant (Monday=1)', () {
        // 2025-12-01 is Monday
        final dt = EasyDateTime.utc(2025, 12, 1);
        expect(dt.weekday, DateTime.monday);
      });

      test('millisecondsSinceEpoch returns ms since Unix epoch (UTC)', () {
        final dt = EasyDateTime.utc(1970, 1, 1, 0, 0, 0);
        expect(dt.millisecondsSinceEpoch, 0);
      });

      test('timeZoneOffset returns difference between local time and UTC', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 12, 15, 0, 0, 0, 0, 0, tokyo);
        // Tokyo is UTC+9 (no DST)
        expect(dt.timeZoneOffset, const Duration(hours: 9));
      });

      test(
          'timeZoneName returns non-empty string identifier (e.g., EST, GMT-5)',
          () {
        final dt = EasyDateTime.now(location: TimeZones.newYork);
        // EST or EDT depending on time, but just checking it returns a string
        expect(dt.timeZoneName, isNotEmpty);
        expect(dt.timeZoneName, anyOf('EST', 'EDT', 'GMT-5', 'GMT-4'));
      });

      test('hashCode returns same value for equal objects', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        expect(dt1.hashCode, dt2.hashCode);
      });

      test('hashCode differs for different moments', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final dt2 = EasyDateTime.utc(2025, 12, 1, 10, 31);
        expect(dt1.hashCode, isNot(dt2.hashCode));
      });

      test('hashCode is identical for same moment in different timezones', () {
        // 10:30 Shanghai (+8) = 11:30 Tokyo (+9) = 02:30 UTC
        final shanghai = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
        final tokyo = EasyDateTime.parse('2025-12-01T11:30:00+09:00');
        expect(shanghai.hashCode, tokyo.hashCode);
      });
    });

    group('Timezone Conversion', () {
      test('inLocation(loc) converts to target timezone preserving moment', () {
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

      test('toUtc() converts to UTC preserving moment', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 12, 1, 9, 0, 0, 0, 0, tokyo);
        final utc = dt.toUtc();

        expect(utc.locationName, 'UTC');
        expect(utc.hour, 0);
        expect(utc.day, 1);
      });

      test('toLocal() converts to system local timezone preserving moment', () {
        final utc = EasyDateTime.utc(2025, 12, 1, 12, 0);
        final local = utc.toLocal();

        // Same moment, but in local timezone
        expect(local.millisecondsSinceEpoch, utc.millisecondsSinceEpoch);
      });

      test('toDateTime() converts to equivalent standard DateTime', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 12, 1, 10, 30, 0, 0, 0, tokyo);
        final stdDt = dt.toDateTime();

        expect(stdDt, isA<DateTime>());
        expect(stdDt.year, 2025);
        expect(stdDt.month, 12);
        expect(stdDt.day, 1);
      });
    });

    group('copyWith', () {
      test('copyWith() returns new instance with updated fields', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final modified = dt.copyWith(year: 2026, month: 6);

        expect(modified.year, 2026);
        expect(modified.month, 6);
        expect(modified.day, 1);
        expect(modified.hour, 10);
      });

      test('copyWith() updates location while preserving other fields', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final tokyo = getLocation('Asia/Tokyo');
        final modified = dt.copyWith(location: tokyo);

        expect(modified.locationName, 'Asia/Tokyo');
        expect(modified.hour, 10);
      });

      group('copyWithClamped', () {
        test('copyWithClamped() clamps day to month end if necessary', () {
          final jan31 = EasyDateTime.utc(2025, 1, 31);
          final feb = jan31.copyWithClamped(month: 2);
          expect(feb.day, 28);
        });

        test('copyWithClamped() handles leap years correctly', () {
          final jan31 = EasyDateTime.utc(2024, 1, 31);
          final feb = jan31.copyWithClamped(month: 2);
          expect(feb.day, 29);
        });

        test('copyWithClamped() adjusts to 30-day month end', () {
          final jan31 = EasyDateTime.utc(2025, 1, 31);
          final apr = jan31.copyWithClamped(month: 4);
          expect(apr.day, 30);
        });

        test('copyWithClamped() does not modify valid days', () {
          final jan15 = EasyDateTime.utc(2025, 1, 15);
          final feb = jan15.copyWithClamped(month: 2);
          expect(feb.day, 15);
        });

        test('copyWithClamped() preserves time components and location', () {
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
    });
  });
}
