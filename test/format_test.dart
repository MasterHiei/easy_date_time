import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('format()', () {
    group('Year tokens', () {
      test('yyyy formats 4-digit year', () {
        final dt = EasyDateTime(2025, 6, 15);
        expect(dt.format('yyyy'), '2025');
      });

      test('yyyy pads year with zeros', () {
        final dt = EasyDateTime(25, 6, 15);
        expect(dt.format('yyyy'), '0025');
      });

      test('yy formats 2-digit year', () {
        final dt = EasyDateTime(2025, 6, 15);
        expect(dt.format('yy'), '25');
      });

      test('yy handles century boundary', () {
        final dt = EasyDateTime(2000, 1, 1);
        expect(dt.format('yy'), '00');
      });
    });

    group('Month tokens', () {
      test('MM formats month with padding', () {
        final dt = EasyDateTime(2025, 1, 15);
        expect(dt.format('MM'), '01');
      });

      test('MM formats double-digit month', () {
        final dt = EasyDateTime(2025, 12, 15);
        expect(dt.format('MM'), '12');
      });

      test('M formats month without padding', () {
        final dt = EasyDateTime(2025, 1, 15);
        expect(dt.format('M'), '1');
      });

      test('M formats double-digit month', () {
        final dt = EasyDateTime(2025, 12, 15);
        expect(dt.format('M'), '12');
      });
    });

    group('Day tokens', () {
      test('dd formats day with padding', () {
        final dt = EasyDateTime(2025, 6, 5);
        expect(dt.format('dd'), '05');
      });

      test('dd formats double-digit day', () {
        final dt = EasyDateTime(2025, 6, 25);
        expect(dt.format('dd'), '25');
      });

      test('d formats day without padding', () {
        final dt = EasyDateTime(2025, 6, 5);
        expect(dt.format('d'), '5');
      });
    });

    group('24-hour tokens', () {
      test('HH formats hour with padding', () {
        final dt = EasyDateTime(2025, 6, 15, 9, 30);
        expect(dt.format('HH'), '09');
      });

      test('HH formats midnight as 00', () {
        final dt = EasyDateTime(2025, 6, 15, 0, 0);
        expect(dt.format('HH'), '00');
      });

      test('HH formats afternoon hour', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30);
        expect(dt.format('HH'), '14');
      });

      test('H formats hour without padding', () {
        final dt = EasyDateTime(2025, 6, 15, 9, 30);
        expect(dt.format('H'), '9');
      });
    });

    group('12-hour tokens', () {
      test('hh formats morning hour', () {
        final dt = EasyDateTime(2025, 6, 15, 9, 30);
        expect(dt.format('hh'), '09');
      });

      test('hh formats afternoon hour as 12-hour', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30);
        expect(dt.format('hh'), '02');
      });

      test('hh formats midnight as 12', () {
        final dt = EasyDateTime(2025, 6, 15, 0, 0);
        expect(dt.format('hh'), '12');
      });

      test('hh formats noon as 12', () {
        final dt = EasyDateTime(2025, 6, 15, 12, 0);
        expect(dt.format('hh'), '12');
      });

      test('h formats without padding', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30);
        expect(dt.format('h'), '2');
      });
    });

    group('Minute tokens', () {
      test('mm formats minutes with padding', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 5);
        expect(dt.format('mm'), '05');
      });

      test('m formats minutes without padding', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 5);
        expect(dt.format('m'), '5');
      });
    });

    group('Second tokens', () {
      test('ss formats seconds with padding', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30, 5);
        expect(dt.format('ss'), '05');
      });

      test('s formats seconds without padding', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30, 5);
        expect(dt.format('s'), '5');
      });
    });

    group('Millisecond tokens', () {
      test('SSS formats milliseconds with padding', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30, 45, 7);
        expect(dt.format('SSS'), '007');
      });

      test('SSS formats 3-digit milliseconds', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30, 45, 123);
        expect(dt.format('SSS'), '123');
      });

      test('S formats milliseconds without padding', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30, 45, 7);
        expect(dt.format('S'), '7');
      });
    });

    group('AM/PM token', () {
      test('a formats AM for morning', () {
        final dt = EasyDateTime(2025, 6, 15, 9, 30);
        expect(dt.format('a'), 'AM');
      });

      test('a formats PM for afternoon', () {
        final dt = EasyDateTime(2025, 6, 15, 14, 30);
        expect(dt.format('a'), 'PM');
      });

      test('a formats AM for midnight', () {
        final dt = EasyDateTime(2025, 6, 15, 0, 0);
        expect(dt.format('a'), 'AM');
      });

      test('a formats PM for noon', () {
        final dt = EasyDateTime(2025, 6, 15, 12, 0);
        expect(dt.format('a'), 'PM');
      });
    });

    group('Complex patterns', () {
      test('ISO date format', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
        expect(dt.format('yyyy-MM-dd'), '2025-12-01');
      });

      test('ISO time format', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
        expect(dt.format('HH:mm:ss'), '14:30:45');
      });

      test('Full datetime with slash separator', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
        expect(dt.format('yyyy/MM/dd HH:mm:ss'), '2025/12/01 14:30:45');
      });

      test('US date format', () {
        final dt = EasyDateTime(2025, 12, 1);
        expect(dt.format('MM/dd/yyyy'), '12/01/2025');
      });

      test('European date format', () {
        final dt = EasyDateTime(2025, 12, 1);
        expect(dt.format('dd/MM/yyyy'), '01/12/2025');
      });

      test('12-hour time with AM/PM', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30);
        expect(dt.format('hh:mm a'), '02:30 PM');
      });

      test('Time with milliseconds', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30, 45, 123);
        expect(dt.format('HH:mm:ss.SSS'), '14:30:45.123');
      });
    });

    group('Escaped text', () {
      test('single quotes escape literal text', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30);
        expect(dt.format("yyyy-MM-dd'T'HH:mm:ss"), '2025-12-01T14:30:00');
      });

      test('escaped text at start', () {
        final dt = EasyDateTime(2025, 12, 1);
        expect(dt.format("'Date:' yyyy-MM-dd"), 'Date: 2025-12-01');
      });

      test('escaped text at end', () {
        final dt = EasyDateTime(2025, 12, 1);
        expect(dt.format("yyyy-MM-dd 'is the date'"), '2025-12-01 is the date');
      });

      test('multiple escaped sections', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30);
        expect(
          dt.format("'Date:' yyyy-MM-dd 'Time:' HH:mm"),
          'Date: 2025-12-01 Time: 14:30',
        );
      });
    });

    group('Non-token characters', () {
      test('passes through literal characters', () {
        final dt = EasyDateTime(2025, 12, 1);
        expect(dt.format('yyyy年MM月dd日'), '2025年12月01日');
      });

      test('handles spaces', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30);
        expect(dt.format('yyyy MM dd HH mm'), '2025 12 01 14 30');
      });
    });
  });

  group('DateTimeFormats constants', () {
    late EasyDateTime dt;

    setUp(() {
      dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
    });

    test('isoDate', () {
      expect(dt.format(DateTimeFormats.isoDate), '2025-12-01');
    });

    test('isoTime', () {
      expect(dt.format(DateTimeFormats.isoTime), '14:30:45');
    });

    test('isoDateTime', () {
      expect(dt.format(DateTimeFormats.isoDateTime), '2025-12-01T14:30:45');
    });

    test('time12Hour', () {
      expect(dt.format(DateTimeFormats.time12Hour), '02:30 PM');
    });

    test('time24Hour', () {
      expect(dt.format(DateTimeFormats.time24Hour), '14:30');
    });

    test('rfc2822', () {
      final dtWithTz =
          EasyDateTime(2025, 12, 1, 14, 30, 45, 0, 0, TimeZones.shanghai);
      expect(
        dtWithTz.format(DateTimeFormats.rfc2822),
        'Mon, 01 Dec 2025 14:30:45 +0800',
      );
    });
  });

  group('New format tokens', () {
    late EasyDateTime dt;

    setUp(() {
      dt = EasyDateTime(2025, 12, 1, 14, 30, 45, 0, 0, TimeZones.tokyo);
    });

    test('EEE formats day-of-week abbreviation', () {
      expect(dt.format('EEE'), 'Mon');
    });

    test('MMM formats month abbreviation', () {
      expect(dt.format('MMM'), 'Dec');
    });

    test('xxxx formats timezone offset without colon', () {
      expect(dt.format('xxxx'), '+0900');
    });

    test('xx formats short timezone offset', () {
      expect(dt.format('xx'), '+09');
    });

    test('X formats Z for UTC', () {
      final utc = EasyDateTime.utc(2025, 12, 1, 14, 30);
      expect(utc.format('X'), 'Z');
    });

    test('X formats offset for non-UTC', () {
      expect(dt.format('X'), '+0900');
    });
  });

  group('format() with timezones', () {
    test('formats correctly in different timezone', () {
      final dt = EasyDateTime(2025, 12, 1, 14, 30, 0, 0, 0, TimeZones.tokyo);
      expect(dt.format('yyyy-MM-dd HH:mm'), '2025-12-01 14:30');
    });

    test('timezone does not affect format output', () {
      final shanghai =
          EasyDateTime(2025, 12, 1, 14, 30, 0, 0, 0, TimeZones.shanghai);
      final newYork =
          EasyDateTime(2025, 12, 1, 14, 30, 0, 0, 0, TimeZones.newYork);

      // Same local time representation despite different timezones
      expect(
        shanghai.format('yyyy-MM-dd HH:mm'),
        newYork.format('yyyy-MM-dd HH:mm'),
      );
    });
  });

  group('Edge cases', () {
    test('empty pattern returns empty string', () {
      final dt = EasyDateTime(2025, 12, 1);
      expect(dt.format(''), '');
    });

    test('pattern with no tokens', () {
      final dt = EasyDateTime(2025, 12, 1);
      expect(dt.format('---'), '---');
    });

    test('handles leap year date', () {
      final dt = EasyDateTime(2024, 2, 29);
      expect(dt.format('yyyy-MM-dd'), '2024-02-29');
    });

    test('handles end of year', () {
      final dt = EasyDateTime(2025, 12, 31, 23, 59, 59);
      expect(dt.format('yyyy-MM-dd HH:mm:ss'), '2025-12-31 23:59:59');
    });

    test('handles start of year', () {
      final dt = EasyDateTime(2025, 1, 1, 0, 0, 0);
      expect(dt.format('yyyy-MM-dd HH:mm:ss'), '2025-01-01 00:00:00');
    });

    test('unclosed quote outputs remaining as literal (WYSIWYG)', () {
      final dt = EasyDateTime(2025, 12, 1);
      // Unclosed quote should output "Date: 2025-12-01" (unclosed quote treated as literal)
      expect(dt.format("'Date: yyyy-MM-dd"), 'Date: yyyy-MM-dd');
    });

    test('single quote at end of pattern', () {
      final dt = EasyDateTime(2025, 12, 1);
      expect(dt.format("yyyy-MM-dd'"), '2025-12-01');
    });

    test('empty quoted section', () {
      final dt = EasyDateTime(2025, 12, 1);
      expect(dt.format("yyyy''MM"), '202512');
    });

    test('handles historical date (year 1)', () {
      final dt = EasyDateTime.utc(1, 1, 1);
      expect(dt.format('yyyy-MM-dd'), '0001-01-01');
    });

    test('handles far future date (year 9999)', () {
      final dt = EasyDateTime.utc(9999, 12, 31);
      expect(dt.format('yyyy-MM-dd'), '9999-12-31');
    });

    test('handles pre-epoch date (1950)', () {
      final dt = EasyDateTime.utc(1950, 6, 15, 10, 30);
      expect(dt.format('yyyy-MM-dd HH:mm'), '1950-06-15 10:30');
    });
  });
}
