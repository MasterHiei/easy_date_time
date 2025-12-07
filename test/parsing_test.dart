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
  });
}
