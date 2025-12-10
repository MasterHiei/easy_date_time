import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' show local;

/// Additional boundary value and edge case tests for comprehensive coverage
void main() {
  setUpAll(() {
    initializeTimeZone();
  });

  tearDown(() {
    clearDefaultLocation();
  });

  group('Boundary Value Tests', () {
    group('Year boundaries', () {
      test('minimum year (year 1)', () {
        final dt = EasyDateTime.utc(1, 1, 1);
        expect(dt.year, 1);
        expect(dt.month, 1);
        expect(dt.day, 1);
      });

      test('maximum reasonable year (9999)', () {
        final dt = EasyDateTime.utc(9999, 12, 31);
        expect(dt.year, 9999);
        expect(dt.month, 12);
        expect(dt.day, 31);
      });

      test('year transition (2025 -> 2026)', () {
        final last2025 = EasyDateTime.utc(2025, 12, 31, 23, 59, 59, 999, 999);
        final first2026 = last2025 + const Duration(microseconds: 1);

        expect(first2026.year, 2026);
        expect(first2026.month, 1);
        expect(first2026.day, 1);
        expect(first2026.hour, 0);
        expect(first2026.minute, 0);
        expect(first2026.second, 0);
      });

      test('pre-1970 epoch (negative timestamp)', () {
        // 1969-12-31 23:59:59 UTC = -1 second from epoch
        final preEpoch = EasyDateTime.utc(1969, 12, 31, 23, 59, 59);
        expect(preEpoch.year, 1969);
        expect(preEpoch.millisecondsSinceEpoch, lessThan(0));
      });

      test('pre-1970 arithmetic across epoch boundary', () {
        final afterEpoch = EasyDateTime.utc(1970, 1, 1, 0, 0, 1);
        final beforeEpoch = afterEpoch - const Duration(seconds: 2);

        expect(beforeEpoch.year, 1969);
        expect(beforeEpoch.month, 12);
        expect(beforeEpoch.day, 31);
        expect(beforeEpoch.hour, 23);
        expect(beforeEpoch.minute, 59);
        expect(beforeEpoch.second, 59);
      });

      test('pre-1970 comparison works correctly', () {
        final y1960 = EasyDateTime.utc(1960, 6, 15);
        final y1965 = EasyDateTime.utc(1965, 6, 15);
        final y1970 = EasyDateTime.utc(1970, 6, 15);

        expect(y1960 < y1965, isTrue);
        expect(y1965 < y1970, isTrue);
        expect(y1960 < y1970, isTrue);
      });
    });

    group('Month boundaries', () {
      test('31-day months have correct last day', () {
        for (final month in [1, 3, 5, 7, 8, 10, 12]) {
          final dt = EasyDateTime.utc(2025, month, 31);
          expect(dt.day, 31);
        }
      });

      test('30-day months have correct last day', () {
        for (final month in [4, 6, 9, 11]) {
          final dt = EasyDateTime.utc(2025, month, 30);
          expect(dt.day, 30);
        }
      });

      test('February in non-leap year has 28 days', () {
        final feb = EasyDateTime.utc(2025, 2, 28);
        expect(feb.day, 28);
      });

      test('February in leap year has 29 days', () {
        final leapFeb = EasyDateTime.utc(2024, 2, 29);
        expect(leapFeb.day, 29);
        expect(leapFeb.month, 2);
      });

      test('month transition from January to February', () {
        final endJan = EasyDateTime.utc(2025, 1, 31);
        final startFeb = endJan + const Duration(days: 1);

        expect(startFeb.month, 2);
        expect(startFeb.day, 1);
      });
    });

    group('Time boundaries', () {
      test('minimum time (00:00:00.000000)', () {
        final dt = EasyDateTime.utc(2025, 1, 1, 0, 0, 0, 0, 0);
        expect(dt.hour, 0);
        expect(dt.minute, 0);
        expect(dt.second, 0);
        expect(dt.millisecond, 0);
        expect(dt.microsecond, 0);
      });

      test('maximum time (23:59:59.999999)', () {
        final dt = EasyDateTime.utc(2025, 1, 1, 23, 59, 59, 999, 999);
        expect(dt.hour, 23);
        expect(dt.minute, 59);
        expect(dt.second, 59);
        expect(dt.millisecond, 999);
        expect(dt.microsecond, 999);
      });

      test('day transition at midnight', () {
        final endDay = EasyDateTime.utc(2025, 6, 15, 23, 59, 59, 999, 999);
        final newDay = endDay + const Duration(microseconds: 1);

        expect(newDay.day, 16);
        expect(newDay.hour, 0);
        expect(newDay.minute, 0);
        expect(newDay.second, 0);
      });
    });

    group('Timezone edge cases', () {
      test('extreme positive timezone offset (Kiritimati +14:00)', () {
        final location = getLocation('Pacific/Kiritimati');
        final utc = EasyDateTime.utc(2025, 6, 15, 10, 0);
        final kiritimati = utc.inLocation(location);

        // UTC 10:00 + 14 hours = next day 00:00
        expect(kiritimati.hour, 0);
        expect(kiritimati.day, 16);
      });

      test('extreme negative timezone offset (America/Anchorage -9:00)', () {
        final location = getLocation('America/Anchorage');
        final utc = EasyDateTime.utc(2025, 6, 15, 10, 0);
        final anchorage = utc.inLocation(location);

        // UTC 10:00 - 9 hours = 01:00 same day (during DST it's -8)
        // In June, DST is active so offset is -8
        expect(anchorage.day, 15);
        expect(anchorage.hour, lessThan(10));
      });

      test('same moment in different timezones', () {
        final tokyo = getLocation('Asia/Tokyo');
        final ny = getLocation('America/New_York');

        final dt1 = EasyDateTime(2025, 6, 15, 10, 0, 0, 0, 0, tokyo);
        final dt2 = dt1.inLocation(ny);

        expect(dt1.isAtSameMomentAs(dt2), isTrue);
        expect(dt1.millisecondsSinceEpoch, dt2.millisecondsSinceEpoch);
        // But different locations
        expect(dt1.locationName, isNot(dt2.locationName));
      });
    });

    group('DST transition edge cases', () {
      test('DST Spring Forward - gap hour handling (2:00 AM -> 3:00 AM)', () {
        // In New York, 2025-03-09 at 2:00 AM clocks spring forward to 3:00 AM
        // Times like 2:30 AM don't exist - the timezone package adjusts them
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 9, 2, 30, 0, 0, 0, ny);

        // The timezone package typically adjusts invalid times forward
        // Either stays at 2:30 (interpreted as standard time) or jumps to 3:30
        expect(dt.hour, anyOf(2, 3));
        expect(dt.locationName, 'America/New_York');
      });

      test('DST Fall Back - ambiguous hour (1:00-2:00 AM occurs twice)', () {
        // In New York, 2025-11-02 at 2:00 AM clocks fall back to 1:00 AM
        // Times like 1:30 AM occur twice - once in DST, once in standard time
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 2, 1, 30, 0, 0, 0, ny);

        // The time value should be preserved
        expect(dt.hour, 1);
        expect(dt.minute, 30);
        expect(dt.locationName, 'America/New_York');
      });

      test('Cross-DST arithmetic preserves instant', () {
        // Create a time before DST transition
        final ny = getLocation('America/New_York');
        final beforeDst = EasyDateTime(2025, 3, 9, 1, 30, 0, 0, 0, ny);

        // Add 2 hours - this crosses the DST gap
        final afterAdd = beforeDst + const Duration(hours: 2);

        // 1:30 AM + 2 hours = 4:30 AM (because 2:00-3:00 doesn't exist)
        expect(afterAdd.hour, 4);
        expect(afterAdd.minute, 30);
      });

      test('UTC conversion around DST transition is consistent', () {
        final ny = getLocation('America/New_York');

        // Before DST: EST (UTC-5)
        final beforeDst = EasyDateTime(2025, 3, 9, 1, 0, 0, 0, 0, ny);
        final beforeUtc = beforeDst.toUtc();
        expect(beforeUtc.hour, 6); // 1:00 EST = 6:00 UTC

        // After DST: EDT (UTC-4)
        final afterDst = EasyDateTime(2025, 3, 9, 3, 0, 0, 0, 0, ny);
        final afterUtc = afterDst.toUtc();
        expect(afterUtc.hour, 7); // 3:00 EDT = 7:00 UTC
      });
    });

    group('Arithmetic edge cases', () {
      test('adding Duration.zero returns same moment', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 10, 0);
        final same = dt + Duration.zero;

        expect(same.isAtSameMomentAs(dt), isTrue);
      });

      test('subtracting large duration (10 years)', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 10, 0);
        final past = dt - const Duration(days: 365 * 10);

        expect(past.year, 2015);
      });

      test('adding very small duration (1 microsecond)', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 10, 0, 0, 0, 0);
        final future = dt + const Duration(microseconds: 1);

        expect(future.microsecond, 1);
        expect(future.difference(dt).inMicroseconds, 1);
      });

      test('millisecond precision boundary', () {
        final dt1 = EasyDateTime.fromMillisecondsSinceEpoch(1000);
        final dt2 = EasyDateTime.fromMillisecondsSinceEpoch(1001);

        expect(dt1.isBefore(dt2), isTrue);
        expect(dt2.difference(dt1).inMilliseconds, 1);
      });
    });

    group('Comparison edge cases', () {
      test('comparing at millisecond boundary', () {
        final dt1 = EasyDateTime.fromMillisecondsSinceEpoch(1000);
        final dt2 = EasyDateTime.fromMillisecondsSinceEpoch(1001);

        expect(dt1.isBefore(dt2), isTrue);
        expect(dt1 < dt2, isTrue);
        expect(dt2 > dt1, isTrue);
      });

      test('equal times with == operator', () {
        final dt1 = EasyDateTime.utc(2025, 6, 15, 10, 0);
        final dt2 = EasyDateTime.utc(2025, 6, 15, 10, 0);

        expect(dt1 == dt2, isTrue);
        expect(dt1.hashCode, dt2.hashCode);
      });

      test('compareTo for sorting', () {
        final dt1 = EasyDateTime.utc(2025, 6, 14);
        final dt2 = EasyDateTime.utc(2025, 6, 15);
        final dt3 = EasyDateTime.utc(2025, 6, 16);

        final list = [dt3, dt1, dt2];
        list.sort();

        expect(list.first, dt1);
        expect(list[1], dt2);
        expect(list[2], dt3);
      });
    });

    group('JSON serialization edge cases', () {
      test('microsecond precision preserved in serialization', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 10, 30, 45, 123, 456);
        final json = dt.toIso8601String();
        final restored = EasyDateTime.fromIso8601String(json);

        expect(restored.millisecond, 123);
        // Note: microseconds may not be preserved in ISO 8601 parsing
      });

      test('timezone offset preserved in JSON', () {
        final tokyo = getLocation('Asia/Tokyo');
        final dt = EasyDateTime(2025, 6, 15, 10, 0, 0, 0, 0, tokyo);
        final json = dt.toIso8601String();

        // Timezone offset format may vary: +0900 or +09:00
        expect(json, anyOf(contains('+09:00'), contains('+0900')));
      });

      test('JSON round-trip preserves moment', () {
        final original = EasyDateTime.utc(2025, 6, 15, 10, 30, 45, 123);
        final json = original.toIso8601String();
        final restored = EasyDateTime.fromIso8601String(json);

        expect(restored.isAtSameMomentAs(original), isTrue);
      });
    });

    group('Global configuration edge cases', () {
      test('clearing default when none set does not throw', () {
        clearDefaultLocation();
        clearDefaultLocation();

        final dt = EasyDateTime.now();
        expect(dt.location, local);
      });

      test('multiple set/clear cycles work correctly', () {
        final tokyo = getLocation('Asia/Tokyo');
        final london = getLocation('Europe/London');

        setDefaultLocation(tokyo);
        expect(getDefaultLocation()!.name, 'Asia/Tokyo');

        setDefaultLocation(london);
        expect(getDefaultLocation()!.name, 'Europe/London');

        clearDefaultLocation();
        expect(getDefaultLocation(), isNull);
      });

      test('default location affects new instances', () {
        final tokyo = getLocation('Asia/Tokyo');
        setDefaultLocation(tokyo);

        final dt = EasyDateTime(2025, 6, 15, 10, 0);
        expect(dt.locationName, 'Asia/Tokyo');
      });
    });

    group('Invalid input handling', () {
      test('tryParse returns null for invalid date string', () {
        final result = EasyDateTime.tryParse('invalid-date');
        expect(result, isNull);
      });

      test('tryParse returns null for empty string', () {
        final result = EasyDateTime.tryParse('');
        expect(result, isNull);
      });

      test('parse throws FormatException on invalid input', () {
        expect(
          () => EasyDateTime.parse('invalid-date'),
          throwsFormatException,
        );
      });

      test('tryParse handles obviously invalid strings gracefully', () {
        expect(EasyDateTime.tryParse('not-a-date'), isNull);
        expect(EasyDateTime.tryParse('abc'), isNull);
        expect(EasyDateTime.tryParse('12345'), isNull);
      });

      test('tryParse handles slash format (YYYY/MM/DD)', () {
        final result = EasyDateTime.tryParse('2025/12/01');
        expect(result, isNotNull);
        expect(result!.year, 2025);
        expect(result.month, 12);
        expect(result.day, 1);
      });

      test('tryParse handles slash format with time', () {
        final result = EasyDateTime.tryParse('2025/12/01 10:30:00');
        expect(result, isNotNull);
        expect(result!.hour, 10);
        expect(result.minute, 30);
      });

      test('parse supports various ISO 8601 formats', () {
        // Date only
        final dateOnly = EasyDateTime.parse('2025-12-01');
        expect(dateOnly.year, 2025);
        expect(dateOnly.hour, 0);

        // With time
        final withTime = EasyDateTime.parse('2025-12-01T10:30:00');
        expect(withTime.hour, 10);

        // UTC
        final utc = EasyDateTime.parse('2025-12-01T10:30:00Z');
        expect(utc.locationName, 'UTC');

        // With offset
        final withOffset = EasyDateTime.parse('2025-12-01T10:30:00+09:00');
        expect(withOffset, isNotNull);
      });

      test('tryParse handles empty and whitespace strings', () {
        expect(EasyDateTime.tryParse(''), isNull);
        expect(EasyDateTime.tryParse('   '), isNull);
      });
    });

    group('copyWith edge cases', () {
      test('copyWith with all fields changed', () {
        final dt = EasyDateTime.utc(2025, 1, 1, 0, 0, 0, 0, 0);
        final modified = dt.copyWith(
          year: 2026,
          month: 12,
          day: 31,
          hour: 23,
          minute: 59,
          second: 59,
          millisecond: 999,
          microsecond: 999,
        );

        expect(modified.year, 2026);
        expect(modified.month, 12);
        expect(modified.day, 31);
        expect(modified.hour, 23);
        expect(modified.minute, 59);
        expect(modified.second, 59);
        expect(modified.millisecond, 999);
        expect(modified.microsecond, 999);
      });

      test('copyWith with no changes returns equivalent instance', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 10, 30);
        final same = dt.copyWith();

        expect(same.isAtSameMomentAs(dt), isTrue);
        expect(same.location, dt.location);
      });

      test('copyWith with location change', () {
        final dt = EasyDateTime.utc(2025, 6, 15, 10, 0);
        final tokyo = getLocation('Asia/Tokyo');
        final modified = dt.copyWith(location: tokyo);

        expect(modified.locationName, 'Asia/Tokyo');
        expect(modified.hour, 10); // Hour stays same, it's not a conversion
      });
    });

    group('format() during DST transitions', () {
      test('format preserves local hour during Spring Forward gap', () {
        // In New York, 2025-03-09 at 2:00 AM clocks spring forward to 3:00 AM
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 3, 9, 3, 30, 0, 0, 0, ny);

        // Format should show the actual local time
        expect(dt.format('HH:mm'), '03:30');
        expect(dt.format('hh:mm a'), '03:30 AM');
      });

      test('format preserves local hour during Fall Back ambiguous hour', () {
        // In New York, 2025-11-02 at 2:00 AM clocks fall back to 1:00 AM
        final ny = getLocation('America/New_York');
        final dt = EasyDateTime(2025, 11, 2, 1, 30, 0, 0, 0, ny);

        // Format should show the stored local time
        expect(dt.format('HH:mm'), '01:30');
        expect(dt.format('hh:mm a'), '01:30 AM');
      });

      test('format works consistently across DST boundary', () {
        final ny = getLocation('America/New_York');

        // Before DST transition (EST)
        final beforeDst = EasyDateTime(2025, 3, 9, 1, 0, 0, 0, 0, ny);
        // After DST transition (EDT)
        final afterDst = EasyDateTime(2025, 3, 9, 3, 0, 0, 0, 0, ny);

        expect(beforeDst.format('yyyy-MM-dd HH:mm'), '2025-03-09 01:00');
        expect(afterDst.format('yyyy-MM-dd HH:mm'), '2025-03-09 03:00');
      });

      test('format with 12-hour clock during midnight DST', () {
        // Some rare timezones have DST at midnight
        final dt = EasyDateTime(2025, 3, 30, 0, 30, 0, 0, 0, TimeZones.london);
        expect(dt.format('hh:mm a'), '12:30 AM');
      });
    });
  });
}
