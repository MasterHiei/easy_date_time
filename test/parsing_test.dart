import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('EasyDateTime Parsing Robustness', () {
    test('tryParse handles standard ISO formats', () {
      expect(EasyDateTime.tryParse('2025-12-01T10:30:00Z'), isNotNull);
      expect(EasyDateTime.tryParse('2025-12-01T10:30:00+09:00'), isNotNull);
      expect(EasyDateTime.tryParse('2025-12-01'), isNotNull);
    });

    test('tryParse handles common fallback formats', () {
      // Slash
      expect(EasyDateTime.tryParse('2025/12/01'), isNotNull,
          reason: 'Slash date');
      expect(EasyDateTime.tryParse('2025/12/01 10:30:00'), isNotNull,
          reason: 'Slash date space time');

      // Dash with space
      expect(EasyDateTime.tryParse('2025-12-01 10:30:00'), isNotNull,
          reason: 'Dash date space time');

      // Dot
      expect(EasyDateTime.tryParse('2025.12.01'), isNotNull,
          reason: 'Dot date');
      expect(EasyDateTime.tryParse('2025.12.01 10:30:00'), isNotNull,
          reason: 'Dot date space time');
    });

    test('tryParse rejects extremely long inputs (ReDoS protection)', () {
      final longString = '2025-12-01${' ' * 1000}10:00';
      // Should return null quickly and not crash/hang
      expect(EasyDateTime.tryParse(longString), isNull);

      final veryLongGarbage = 'a' * 200;
      expect(EasyDateTime.tryParse(veryLongGarbage), isNull);
    });

    test('tryParse rejects invalid components in fallback format', () {
      // Month 13
      expect(EasyDateTime.tryParse('2025/13/01'), isNull);
      // Day 32
      expect(EasyDateTime.tryParse('2025/12/32'), isNull);
      // Garbage year
      expect(EasyDateTime.tryParse('202A/12/01'), isNull);
    });

    test('tryParse handles T prefix in time part correctly', () {
      // Allow time part with T even in fallback if regex matches
      // Though "2025/12/01T10:30:00" might be matched by generic regex logic
      expect(EasyDateTime.tryParse('2025/12/01T10:30:00'), isNotNull);
    });

    test('tryParse is robust against leading/trailing whitespace', () {
      expect(EasyDateTime.tryParse('  2025-12-01T10:00:00Z  '), isNotNull);
      expect(EasyDateTime.tryParse('  2025/12/01  '), isNotNull);
    });

    test('parse correctly handles uncommon timezone offsets', () {
      // Nepal time +5:45 - should find matching timezone
      final nepal = EasyDateTime.parse('2025-12-01T10:00:00+05:45');
      expect(nepal.hour, 10); // Original hour preserved
      expect(nepal.locationName, 'Asia/Kathmandu');
    });

    test('parse throws InvalidTimeZoneException for non-standard offset', () {
      // +05:17 is not a valid IANA timezone offset
      expect(
        () => EasyDateTime.parse('2025-12-01T10:00:00+05:17'),
        throwsA(isA<InvalidTimeZoneException>()),
      );
    });

    test('tryParse returns null for non-standard offset', () {
      // tryParse should gracefully return null instead of throwing
      final result = EasyDateTime.tryParse('2025-12-01T10:00:00+05:17');
      expect(result, isNull);
    });

    test('parse handles DST offsets correctly', () {
      // EDT (Eastern Daylight Time) is -04:00
      final edt = EasyDateTime.parse('2025-07-01T10:00:00-04:00');
      expect(edt.hour, 10); // Original hour preserved
      // Should match America/New_York which uses EDT in summer
      expect(edt.locationName, 'America/New_York');
    });
    group('Edge cases (migrated from core_coverage)', () {
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

    group('Timezone offset parsing covers various offsets (migrated)', () {
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

      test('parses -03:30 offset (St. Johns) triggers fallback lookup', () {
        // -03:30 is not in _commonOffsetMappings, so this hits the fallback loop
        final dt = EasyDateTime.parse('2025-12-01T10:00:00-03:30');
        expect(dt.hour, 10);
        expect(dt.locationName, 'America/St_Johns');
      });
    });
  });
}
