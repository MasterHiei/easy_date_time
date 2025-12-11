import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('Core functionality coverage tests', () {
    group('Date utilities', () {
      test('tomorrow returns next day', () {
        final dt = EasyDateTime.utc(2025, 12, 15, 10, 30);
        final next = dt.tomorrow;

        expect(next.day, 16);
        expect(next.hour, 10);
        expect(next.minute, 30);
      });

      test('yesterday returns previous day', () {
        final dt = EasyDateTime.utc(2025, 12, 15, 10, 30);
        final prev = dt.yesterday;

        expect(prev.day, 14);
        expect(prev.hour, 10);
        expect(prev.minute, 30);
      });

      test('isToday returns true for today', () {
        final now = EasyDateTime.now();
        expect(now.isToday, isTrue);
      });

      test('isToday returns false for other days', () {
        final yesterday = EasyDateTime.now().yesterday;
        expect(yesterday.isToday, isFalse);
      });

      test('isTomorrow returns true for tomorrow', () {
        final tomorrow = EasyDateTime.now().tomorrow;
        expect(tomorrow.isTomorrow, isTrue);
      });

      test('isTomorrow returns false for today', () {
        final now = EasyDateTime.now();
        expect(now.isTomorrow, isFalse);
      });

      test('isYesterday returns true for yesterday', () {
        final yesterday = EasyDateTime.now().yesterday;
        expect(yesterday.isYesterday, isTrue);
      });

      test('isYesterday returns false for today', () {
        final now = EasyDateTime.now();
        expect(now.isYesterday, isFalse);
      });

      test('startOfDay returns 00:00:00', () {
        final dt = EasyDateTime.utc(2025, 12, 15, 14, 30, 45);
        final start = dt.startOfDay;

        expect(start.hour, 0);
        expect(start.minute, 0);
        expect(start.second, 0);
        expect(start.day, 15);
      });

      test('endOfDay returns 23:59:59', () {
        final dt = EasyDateTime.utc(2025, 12, 15, 14, 30, 45);
        final end = dt.endOfDay;

        expect(end.hour, 23);
        expect(end.minute, 59);
        expect(end.second, 59);
      });

      test('startOfMonth returns first day', () {
        final dt = EasyDateTime.utc(2025, 12, 15, 14, 30);
        final start = dt.startOfMonth;

        expect(start.day, 1);
        expect(start.hour, 0);
        expect(start.minute, 0);
      });

      test('endOfMonth returns last day', () {
        final dt = EasyDateTime.utc(2025, 12, 15);
        final end = dt.endOfMonth;

        expect(end.day, 31);
        expect(end.hour, 23);
        expect(end.minute, 59);
      });

      test('endOfMonth handles February correctly', () {
        final dt = EasyDateTime.utc(2025, 2, 15);
        final end = dt.endOfMonth;
        expect(end.day, 28); // Non-leap year

        final dtLeap = EasyDateTime.utc(2024, 2, 15);
        final endLeap = dtLeap.endOfMonth;
        expect(endLeap.day, 29); // Leap year
      });

      test('endOfMonth handles December correctly', () {
        final dt = EasyDateTime.utc(2025, 12, 15);
        final end = dt.endOfMonth;
        expect(end.day, 31);
        expect(end.month, 12);
        expect(end.year, 2025);
      });

      test('toDateString returns YYYY-MM-DD format', () {
        final dt = EasyDateTime.utc(2025, 12, 1);
        expect(dt.toDateString(), '2025-12-01');
      });

      test('toTimeString returns HH:MM:SS format', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 14, 30, 45);
        expect(dt.toTimeString(), '14:30:45');
      });
    });

    group('Parsing edge cases', () {
      test('parse date with time and offset', () {
        final dt = EasyDateTime.parse('2025-12-01T00:00:00+08:00');
        expect(dt.year, 2025);
        expect(dt.month, 12);
        expect(dt.day, 1);
        expect(dt.hour, 0);
      });

      test('tryParse returns null for empty string', () {
        expect(EasyDateTime.tryParse(''), isNull);
      });

      test('tryParse returns null for whitespace only', () {
        expect(EasyDateTime.tryParse('   '), isNull);
      });

      test('parse with negative timezone offset', () {
        final dt = EasyDateTime.parse('2025-12-01T10:00:00-05:00');
        expect(dt.hour, 10);
        expect(dt.locationName, 'America/New_York');
      });

      test('parse handles fractional seconds', () {
        final dt = EasyDateTime.parse('2025-12-01T10:30:45.123456Z');
        expect(dt.millisecond, 123);
        expect(dt.microsecond, 456);
      });

      test('parse with explicit location converts timezone', () {
        // This tests line 244 - parse with location parameter
        final dt = EasyDateTime.parse(
          '2025-12-01T10:00:00Z',
          location: TimeZones.tokyo,
        );
        expect(dt.hour, 19); // 10:00 UTC = 19:00 Tokyo
        expect(dt.locationName, 'Asia/Tokyo');
      });

      test('parse with location for offset string', () {
        final dt = EasyDateTime.parse(
          '2025-12-01T10:00:00+08:00',
          location: TimeZones.newYork,
        );
        // Should convert: 10:00+08:00 = 02:00 UTC = 21:00 prev day NY
        expect(dt.locationName, 'America/New_York');
      });

      test('parse date-only with offset triggers different path', () {
        // Date-only format without time but with default timezone
        final dt = EasyDateTime.parse('2025-12-01');
        expect(dt.year, 2025);
        expect(dt.month, 12);
        expect(dt.day, 1);
        expect(dt.hour, 0);
      });

      test('tryParse handles invalid format gracefully', () {
        expect(EasyDateTime.tryParse('not-a-date'), isNull);
        expect(EasyDateTime.tryParse('invalid-date-format'), isNull);
      });
    });

    group('Timezone operations', () {
      test('inLocation preserves moment', () {
        final tokyo = EasyDateTime(
          2025,
          12,
          1,
          12,
          0,
          0,
          0,
          0,
          TimeZones.tokyo,
        );
        final ny = tokyo.inLocation(TimeZones.newYork);

        expect(tokyo.microsecondsSinceEpoch, ny.microsecondsSinceEpoch);
        expect(ny.locationName, 'America/New_York');
      });

      test('toUtc preserves moment', () {
        final tokyo = EasyDateTime(
          2025,
          12,
          1,
          12,
          0,
          0,
          0,
          0,
          TimeZones.tokyo,
        );
        final utc = tokyo.toUtc();

        expect(tokyo.microsecondsSinceEpoch, utc.microsecondsSinceEpoch);
        expect(utc.locationName, 'UTC');
      });

      test('toDateTime returns DateTime', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final stdDt = dt.toDateTime();

        expect(stdDt, isA<DateTime>());
        expect(stdDt.year, 2025);
      });
    });

    group('Comparison operators', () {
      test('< operator works correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1 < dt2, isTrue);
        expect(dt2 < dt1, isFalse);
      });

      test('> operator works correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1 > dt2, isTrue);
        expect(dt2 > dt1, isFalse);
      });

      test('<= operator works correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        final dt3 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1 <= dt2, isTrue);
        expect(dt1 <= dt3, isTrue);
      });

      test('>= operator works correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);
        final dt3 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1 >= dt2, isTrue);
        expect(dt1 >= dt3, isTrue);
      });

      test('isBefore works correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);

        expect(dt1.isBefore(dt2), isTrue);
        expect(dt2.isBefore(dt1), isFalse);
      });

      test('isAfter works correctly', () {
        final dt1 = EasyDateTime.utc(2025, 12, 2);
        final dt2 = EasyDateTime.utc(2025, 12, 1);

        expect(dt1.isAfter(dt2), isTrue);
        expect(dt2.isAfter(dt1), isFalse);
      });
    });

    group('Duration operators', () {
      test('+ operator adds duration', () {
        final dt = EasyDateTime.utc(2025, 12, 1);
        final result = dt + const Duration(days: 1);

        expect(result.day, 2);
      });

      test('- operator subtracts duration', () {
        final dt = EasyDateTime.utc(2025, 12, 2);
        final result = dt - const Duration(days: 1);

        expect(result.day, 1);
      });

      test('difference returns Duration', () {
        final dt1 = EasyDateTime.utc(2025, 12, 1);
        final dt2 = EasyDateTime.utc(2025, 12, 2);

        expect(dt2.difference(dt1), const Duration(days: 1));
      });
    });

    group('Constructors', () {
      test('fromMillisecondsSinceEpoch creates correct datetime', () {
        final timestamp = DateTime.utc(2025, 1, 1).millisecondsSinceEpoch;
        final dt = EasyDateTime.fromMillisecondsSinceEpoch(timestamp);

        expect(dt.year, 2025);
        expect(dt.month, 1);
        expect(dt.day, 1);
      });

      test('fromSecondsSinceEpoch creates correct datetime', () {
        // Unix timestamp for 2025-01-01 00:00:00 UTC
        const unixSeconds = 1735689600;
        final dt = EasyDateTime.fromSecondsSinceEpoch(unixSeconds);

        expect(dt.year, 2025);
        expect(dt.month, 1);
        expect(dt.day, 1);
      });

      test('fromSecondsSinceEpoch with location converts correctly', () {
        const unixSeconds = 1735689600; // 2025-01-01 00:00:00 UTC
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime.fromSecondsSinceEpoch(
          unixSeconds,
          location: tokyo,
        );

        expect(dt.hour, 9); // UTC 0:00 = Tokyo 9:00
        expect(dt.locationName, 'Asia/Tokyo');
      });

      test('fromDateTime with location converts correctly', () {
        final stdDt = DateTime.utc(2025, 12, 1, 0, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final easyDt = EasyDateTime.fromDateTime(stdDt, location: tokyo);

        expect(easyDt.hour, 9); // UTC 0:00 = Tokyo 9:00
        expect(easyDt.locationName, 'Asia/Tokyo');
      });
    });

    group('Properties', () {
      test('timeZoneOffset returns correct offset', () {
        final tokyo = EasyDateTime(
          2025,
          12,
          1,
          12,
          0,
          0,
          0,
          0,
          TimeZones.tokyo,
        );
        expect(tokyo.timeZoneOffset, const Duration(hours: 9));
      });

      test('timeZoneName returns correct name', () {
        final tokyo = EasyDateTime(
          2025,
          12,
          1,
          12,
          0,
          0,
          0,
          0,
          TimeZones.tokyo,
        );
        expect(tokyo.timeZoneName, isNotEmpty);
      });

      test('weekday returns correct day', () {
        // 2025-12-01 is Monday
        final dt = EasyDateTime.utc(2025, 12, 1);
        expect(dt.weekday, DateTime.monday);
      });
    });

    group('Format offset helper', () {
      test('parse throws for invalid offset', () {
        expect(
          () => EasyDateTime.parse('2025-12-01T10:00:00+05:17'),
          throwsA(isA<InvalidTimeZoneException>()),
        );
      });
    });

    group('TryParse fallback formats', () {
      test('parses YYYY/MM/DD with time', () {
        final dt = EasyDateTime.tryParse('2025/12/01 10:30:00');
        expect(dt, isNotNull);
        expect(dt!.hour, 10);
        expect(dt.minute, 30);
      });

      test('parses YYYY.MM.DD format', () {
        final dt = EasyDateTime.tryParse('2025.12.01');
        expect(dt, isNotNull);
        expect(dt!.year, 2025);
        expect(dt.month, 12);
        expect(dt.day, 1);
      });

      test('parses YYYY/MM/DD with T prefix', () {
        final dt = EasyDateTime.tryParse('2025/12/01T10:30:00');
        expect(dt, isNotNull);
      });

      test('rejects very long strings', () {
        final longInput = '2025/12/01${'0' * 100}';
        expect(EasyDateTime.tryParse(longInput), isNull);
      });

      test('tryParse rejects invalid month in slash format', () {
        final dt = EasyDateTime.tryParse('2025/15/01');
        expect(dt, isNull);
      });

      test('tryParse rejects invalid day in slash format', () {
        final dt = EasyDateTime.tryParse('2025/12/40');
        expect(dt, isNull);
      });
    });

    group('Additional properties', () {
      test('isUtc returns true for UTC datetime', () {
        final utc = EasyDateTime.utc(2025, 12, 1);
        expect(utc.isUtc, isTrue);
      });

      test('isUtc returns false for non-UTC datetime', () {
        final tokyo = EasyDateTime(
          2025,
          12,
          1,
          12,
          0,
          0,
          0,
          0,
          TimeZones.tokyo,
        );
        expect(tokyo.isUtc, isFalse);
      });
    });

    group('copyWith variations', () {
      test('copyWith with location changes timezone', () {
        final utc = EasyDateTime.utc(2025, 12, 1, 12, 0);
        final tokyo = utc.copyWith(location: TimeZones.tokyo);

        expect(tokyo.locationName, 'Asia/Tokyo');
      });

      test('copyWith with year', () {
        final dt = EasyDateTime.utc(2025, 12, 1);
        final changed = dt.copyWith(year: 2026);
        expect(changed.year, 2026);
      });

      test('copyWith with day', () {
        final dt = EasyDateTime.utc(2025, 12, 1);
        final changed = dt.copyWith(day: 15);
        expect(changed.day, 15);
      });

      test('copyWith with second', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30, 0);
        final changed = dt.copyWith(second: 45);
        expect(changed.second, 45);
      });

      test('copyWith with microsecond', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30, 0, 0, 0);
        final changed = dt.copyWith(microsecond: 123);
        expect(changed.microsecond, 123);
      });
    });

    group('copyWithClamped variations', () {
      test('copyWithClamped preserves year when not specified', () {
        final dt = EasyDateTime.utc(2025, 1, 31);
        final clamped = dt.copyWithClamped(month: 2);

        expect(clamped.year, 2025);
      });

      test('copyWithClamped with day smaller than month max', () {
        final dt = EasyDateTime.utc(2025, 1, 15);
        final clamped = dt.copyWithClamped(month: 2, day: 10);

        expect(clamped.day, 10);
      });
    });

    group('toString and toIso8601String', () {
      test('toString returns readable format', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30);
        expect(dt.toString(), contains('2025'));
      });

      test('toIso8601String returns ISO format', () {
        final dt = EasyDateTime.utc(2025, 12, 1, 10, 30);
        final iso = dt.toIso8601String();
        expect(iso, contains('2025-12-01'));
        expect(iso, contains('10:30'));
      });
    });

    group('Timezone offset parsing covers various offsets', () {
      test('parses +00:00 offset as UTC', () {
        final dt = EasyDateTime.parse('2025-12-01T10:00:00+00:00');
        expect(dt.locationName, 'UTC');
      });

      test('parses +01:00 offset', () {
        final dt = EasyDateTime.parse('2025-12-01T10:00:00+01:00');
        expect(dt.hour, 10);
      });

      test('parses +05:00 offset', () {
        final dt = EasyDateTime.parse('2025-12-01T10:00:00+05:00');
        expect(dt.hour, 10);
      });

      test('parses +09:00 offset as Tokyo', () {
        final dt = EasyDateTime.parse('2025-12-01T10:00:00+09:00');
        expect(dt.locationName, 'Asia/Tokyo');
      });

      test('parses +09:30 offset as Adelaide', () {
        final dt = EasyDateTime.parse('2025-12-01T10:00:00+09:30');
        expect(dt.hour, 10);
      });
    });
  });
}
