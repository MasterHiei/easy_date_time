import 'package:easy_date_time/easy_date_time.dart';

import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('EasyDateTimeFormatter', () {
    test('formats simple tokens correctly', () {
      final formatter = EasyDateTimeFormatter('yyyy-MM-dd');
      final dt = EasyDateTime(2025, 12, 1);
      expect(formatter.format(dt), '2025-12-01');
    });

    test('formats time tokens correctly', () {
      final formatter = EasyDateTimeFormatter('HH:mm:ss');
      final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
      expect(formatter.format(dt), '14:30:45');
    });

    test('reuses formatter instance for multiple dates', () {
      final formatter = EasyDateTimeFormatter('yyyy-MM-dd');
      final dt1 = EasyDateTime(2025, 1, 1);
      final dt2 = EasyDateTime(2025, 12, 31);

      expect(formatter.format(dt1), '2025-01-01');
      expect(formatter.format(dt2), '2025-12-31');
    });

    test('handles escaped text', () {
      final formatter = EasyDateTimeFormatter("'Date:' yyyy-MM-dd");
      final dt = EasyDateTime(2025, 12, 1);
      expect(formatter.format(dt), 'Date: 2025-12-01');
    });

    test('handles complicated pattern', () {
      final formatter = EasyDateTimeFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS 'Z'");
      final dt = EasyDateTime(2025, 6, 15, 14, 30, 45, 123);
      expect(formatter.format(dt), '2025-06-15T14:30:45.123 Z');
    });

    test('handles literal characters mixed with tokens', () {
      final formatter = EasyDateTimeFormatter('yyyy/MM/dd HH:mm');
      final dt = EasyDateTime(2025, 6, 15, 14, 30);
      expect(formatter.format(dt), '2025/06/15 14:30');
    });

    test('handles 12-hour format with AM/PM', () {
      final formatter = EasyDateTimeFormatter('hh:mm a');
      final dtAM = EasyDateTime(2025, 6, 15, 9, 30);
      final dtPM = EasyDateTime(2025, 6, 15, 14, 30);

      expect(formatter.format(dtAM), '09:30 AM');
      expect(formatter.format(dtPM), '02:30 PM');
    });

    test('handles timezone awareness (same moment, different representation)',
        () {
      final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');

      // UTC
      final utc = EasyDateTime.utc(2025, 1, 1, 0, 0); // 00:00 UTC
      // NY (-5)
      final ny = utc.inLocation(TimeZones.newYork); // 19:00 Previous Day

      expect(formatter.format(utc), '2025-01-01 00:00');
      expect(formatter.format(ny), '2024-12-31 19:00');
    });

    test('handles empty pattern', () {
      final formatter = EasyDateTimeFormatter('');
      final dt = EasyDateTime(2025, 1, 1);
      expect(formatter.format(dt), '');
    });

    test('handles pattern with no tokens', () {
      final formatter = EasyDateTimeFormatter('No Token');
      final dt = EasyDateTime(2025, 1, 1);
      expect(formatter.format(dt), 'No Token');
    });

    test('replaces tokens in literal text unless escaped', () {
      // 's' is a token for seconds. 't', 'e', 'x', 't' are not tokens.
      final formatter = EasyDateTimeFormatter('test');
      final dt = EasyDateTime(2025, 1, 1, 10, 30, 05);
      expect(formatter.format(dt), 'te5t'); // s -> 5
    });

    test('handles unclosed quote (WYSIWYG)', () {
      final formatter = EasyDateTimeFormatter("'Unclosed");
      final dt = EasyDateTime(2025, 1, 1);
      expect(formatter.format(dt), 'Unclosed');
    });

    test('handles unpadded 12-hour format (h token)', () {
      final formatter = EasyDateTimeFormatter('h:m:s a');
      final dtMorning = EasyDateTime(2025, 6, 15, 9, 5, 3);
      final dtAfternoon = EasyDateTime(2025, 6, 15, 14, 30, 45);
      final dtMidnight = EasyDateTime(2025, 6, 15, 0, 0, 0);
      final dtNoon = EasyDateTime(2025, 6, 15, 12, 0, 0);

      expect(formatter.format(dtMorning), '9:5:3 AM');
      expect(formatter.format(dtAfternoon), '2:30:45 PM');
      expect(formatter.format(dtMidnight), '12:0:0 AM'); // midnight = 12 AM
      expect(formatter.format(dtNoon), '12:0:0 PM'); // noon = 12 PM
    });

    test('handles unpadded minute and second tokens (m, s)', () {
      final formatter = EasyDateTimeFormatter('H:m:s');
      final dt = EasyDateTime(2025, 1, 1, 5, 3, 7);
      expect(formatter.format(dt), '5:3:7');
    });

    test('handles default token branch for unknown tokens', () {
      // Single characters that are not tokens should pass through
      final formatter = EasyDateTimeFormatter('XYZ');
      final dt = EasyDateTime(2025, 1, 1);
      expect(formatter.format(dt), 'XYZ');
    });
  });
}
