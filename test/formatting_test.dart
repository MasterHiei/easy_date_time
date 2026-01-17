import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  group('EasyDateTime Formatting', () {
    group('Token Formatting', () {
      late EasyDateTime dt;

      setUp(() {
        dt = EasyDateTime(2025, 6, 15, 14, 5, 9, 123);
      });

      test('format() processes Year tokens (yyyy, yy)', () {
        expect(dt.format('yyyy'), '2025');
        expect(EasyDateTime(25, 1, 1).format('yyyy'), '0025');
        expect(dt.format('yy'), '25');
        expect(EasyDateTime(2000, 1, 1).format('yy'), '00');
      });

      test('format() processes Month tokens (MM, M, MMM)', () {
        // June (06)
        expect(dt.format('MM'), '06');
        expect(dt.format('M'), '6');
        expect(dt.format('MMM'), 'Jun');

        final dec = EasyDateTime(2025, 12, 1);
        expect(dec.format('MM'), '12');
        expect(dec.format('M'), '12');
        expect(dec.format('MMM'), 'Dec');
      });

      test('format() processes Day tokens (dd, d, EEE)', () {
        // 15th (Sunday)
        expect(dt.format('dd'), '15');
        expect(dt.format('d'), '15');
        expect(dt.format('EEE'), 'Sun');

        final singleDigit = EasyDateTime(2025, 6, 5);
        expect(singleDigit.format('dd'), '05');
        expect(singleDigit.format('d'), '5');
      });

      test('Hour tokens (HH, H, hh, h)', () {
        // 14:05 (2:05 PM)
        expect(dt.format('HH'), '14');
        expect(dt.format('H'), '14');
        expect(dt.format('hh'), '02');
        expect(dt.format('h'), '2');

        final morning = EasyDateTime(2025, 6, 15, 9, 30);
        expect(morning.format('HH'), '09');
        expect(morning.format('H'), '9');
        expect(morning.format('hh'), '09');
        expect(morning.format('h'), '9');

        final midnight = EasyDateTime(2025, 6, 15, 0, 0);
        expect(midnight.format('HH'), '00');
        expect(midnight.format('hh'), '12'); // 12 AM

        final noon = EasyDateTime(2025, 6, 15, 12, 0);
        expect(noon.format('HH'), '12');
        expect(noon.format('hh'), '12'); // 12 PM
      });

      test('Minute tokens (mm, m)', () {
        // 05 minutes
        expect(dt.format('mm'), '05');
        expect(dt.format('m'), '5');
      });

      test('Second tokens (ss, s)', () {
        // 09 seconds
        expect(dt.format('ss'), '09');
        expect(dt.format('s'), '9');
      });

      test('Millisecond tokens (SSS, S)', () {
        // 123 ms
        expect(dt.format('SSS'), '123');
        expect(EasyDateTime(2025, 1, 1, 0, 0, 0, 5).format('SSS'), '005');
        expect(EasyDateTime(2025, 1, 1, 0, 0, 0, 5).format('S'), '5');
      });

      test('AM/PM token (a)', () {
        expect(dt.format('a'), 'PM');
        expect(EasyDateTime(2025, 6, 15, 9, 30).format('a'), 'AM');
        expect(EasyDateTime(2025, 6, 15, 0, 0).format('a'), 'AM');
        expect(EasyDateTime(2025, 6, 15, 12, 0).format('a'), 'PM');
      });

      test('Timezone tokens (x series, X)', () {
        // Using +09:00 (Tokyo) for predictable testing
        final tokyo =
            EasyDateTime(2025, 1, 1, 0, 0, 0, 0, 0, getLocation('Asia/Tokyo'));

        expect(tokyo.format('xxxxx'), '+09:00');
        expect(tokyo.format('xxxx'), '+0900');
        expect(tokyo.format('xx'), '+09');
        expect(tokyo.format('X'), '+0900');

        final utc = EasyDateTime.utc(2025, 1, 1);
        expect(utc.format('X'), 'Z');
        expect(utc.format('xxxxx'), '+00:00');

        final mumbai = EasyDateTime(
            2025, 1, 1, 0, 0, 0, 0, 0, getLocation('Asia/Kolkata'));
        expect(mumbai.format('xx'), '+0530'); // Special case for minutes
      });
    });

    group('Complex Patterns & Escaping', () {
      late EasyDateTime dt;

      setUp(() {
        dt = EasyDateTime(2025, 12, 1, 14, 30, 45, 123);
      });

      test('Standard ISO formats', () {
        expect(dt.format('yyyy-MM-dd'), '2025-12-01');
        expect(dt.format('HH:mm:ss'), '14:30:45');
        expect(dt.format('yyyy-MM-dd HH:mm:ss'), '2025-12-01 14:30:45');
        expect(dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'),
            '2025-12-01T14:30:45.123');
      });

      test('Regional formats', () {
        expect(dt.format('MM/dd/yyyy'), '12/01/2025'); // US
        expect(dt.format('dd/MM/yyyy'), '01/12/2025'); // EU
        expect(dt.format('hh:mm a'), '02:30 PM'); // 12-hour
        expect(dt.format('yyyy年MM月dd日'), '2025年12月01日'); // CJK
      });

      test('Escaped text handling', () {
        expect(dt.format("'Date:' yyyy-MM-dd"), 'Date: 2025-12-01');
        expect(dt.format("yyyy-MM-dd 'at' HH:mm"), '2025-12-01 at 14:30');
        expect(dt.format("'T'"), 'T'); // Single character escape
        expect(dt.format("''"), ''); // Empty quotes
        expect(dt.format("'Unclosed quotes"),
            'Unclosed quotes'); // WYSIWYG behavior
      });

      test('Literal pass-through', () {
        expect(dt.format('---'), '---');
        expect(dt.format('yyyy/MM/dd'), '2025/12/01');
        expect(dt.format('yyyy MM dd'), '2025 12 01');
      });

      test('Unknown tokens behavior', () {
        // 'Q', 'W', 'Z' (except X, etc) are not tokens
        expect(dt.format('QWZ'), 'QWZ');
      });
    });

    group('EasyDateTimeFormatter Class', () {
      late EasyDateTime dt;

      setUp(() {
        dt = EasyDateTime(2025, 12, 15, 14, 30, 45);
      });

      test('Constructor and format()', () {
        final formatter = EasyDateTimeFormatter('yyyy-MM-dd');
        expect(formatter.format(dt), '2025-12-15');
        expect(formatter.pattern, 'yyyy-MM-dd');
      });

      test('Named constructors', () {
        expect(EasyDateTimeFormatter.isoDate().format(dt), '2025-12-15');
        expect(EasyDateTimeFormatter.isoTime().format(dt), '14:30:45');
        expect(EasyDateTimeFormatter.isoDateTime().format(dt),
            '2025-12-15T14:30:45');
        expect(EasyDateTimeFormatter.time12Hour().format(dt), '02:30 PM');
        expect(EasyDateTimeFormatter.time24Hour().format(dt), '14:30');

        final rfcDt = EasyDateTime.utc(2025, 12, 15, 14, 30, 45);
        expect(EasyDateTimeFormatter.rfc2822().format(rfcDt),
            'Mon, 15 Dec 2025 14:30:45 +0000');
      });

      test('Instance caching', () {
        final f1 = EasyDateTimeFormatter('yyyy-MM-dd');
        final f2 = EasyDateTimeFormatter('yyyy-MM-dd');
        final f3 = EasyDateTimeFormatter.isoDate();
        final f4 = EasyDateTimeFormatter.isoDate();

        expect(identical(f1, f2), isTrue);
        expect(identical(f3, f4), isTrue);
        // Note: 'yyyy-MM-dd' is the pattern for isoDate, so they might share instance
        // depending on implementation. Assuming implementation normalizes.
        // Actually, looking at implementation, DateTimeFormats.isoDate string is used.
        expect(identical(f1, f3), isTrue);
      });

      test('Cache clearing', () {
        final f1 = EasyDateTimeFormatter.isoDate();
        EasyDateTimeFormatter.clearCache();
        final f2 = EasyDateTimeFormatter.isoDate();
        expect(identical(f1, f2), isFalse);
      });

      test('Composition (combineFormatters, addPattern)', () {
        final dateFmt = EasyDateTimeFormatter.isoDate();
        final timeFmt = EasyDateTimeFormatter(' HH:mm');

        final combined = dateFmt.combineFormatters(timeFmt);
        expect(combined.format(dt), '2025-12-15 14:30');

        final extended = dateFmt.addPattern(" 'at' HH:mm");
        expect(extended.format(dt), '2025-12-15 at 14:30');
      });
    });

    group('Edge Cases', () {
      test('Empty pattern', () {
        expect(EasyDateTime(2025, 1, 1).format(''), '');
        expect(EasyDateTimeFormatter('').format(EasyDateTime(2025, 1, 1)), '');
      });

      test('Date boundaries', () {
        // Year 1
        expect(EasyDateTime.utc(1, 1, 1).format('yyyy'), '0001');
        // Year 9999
        expect(EasyDateTime.utc(9999, 12, 31).format('yyyy'), '9999');
        // Leap day
        expect(EasyDateTime(2024, 2, 29).format('yyyy-MM-dd'), '2024-02-29');
      });

      test('Timezone specific formatting equality', () {
        final shanghai = EasyDateTime(
            2025, 12, 1, 10, 0, 0, 0, 0, getLocation('Asia/Shanghai'));
        final newYork = EasyDateTime(
            2025, 12, 1, 10, 0, 0, 0, 0, getLocation('America/New_York'));

        // format() outputs the LOCAL components, so they should look identical
        // even though they represent different absolute moments
        expect(shanghai.format('HH:mm'), newYork.format('HH:mm'));
      });
    });

    group('toDateString / toTimeString', () {
      test('toDateString formats correctly', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
        expect(dt.toDateString(), '2025-12-01');
      });

      test('toDateString pads single digits', () {
        final dt = EasyDateTime(2025, 1, 5);
        expect(dt.toDateString(), '2025-01-05');
      });

      test('toTimeString formats correctly', () {
        final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);
        expect(dt.toTimeString(), '14:30:45');
      });

      test('toTimeString pads single digits', () {
        final dt = EasyDateTime(2025, 12, 1, 9, 5, 3);
        expect(dt.toTimeString(), '09:05:03');
      });
    });
  });
}
