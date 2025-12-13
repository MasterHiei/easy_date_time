import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    EasyDateTime.initializeTimeZone();
  });

  group('Exception toString()', () {
    test('TimeZoneNotInitializedException toString', () {
      final e = TimeZoneNotInitializedException('Test message');

      expect(e.toString(), contains('TimeZoneNotInitializedException'));
      expect(e.toString(), contains('Test message'));
    });

    test('InvalidDateFormatException toString', () {
      final e = InvalidDateFormatException(
        source: 'invalid-date',
        message: 'Could not parse',
        offset: 5,
      );

      expect(e.toString(), contains('InvalidDateFormatException'));
      expect(e.toString(), contains('invalid-date'));
      expect(e.toString(), contains('Could not parse'));
      expect(e.toString(), contains('offset 5'));
    });

    test('InvalidDateFormatException without offset', () {
      final e = InvalidDateFormatException(
        source: 'bad-input',
        message: 'Parse error',
      );

      expect(e.toString(), contains('bad-input'));
      expect(e.toString(), isNot(contains('offset')));
    });

    test('InvalidTimeZoneException toString', () {
      final e = InvalidTimeZoneException(
        timeZoneId: 'Invalid/Zone',
        message: 'Not found',
      );

      expect(e.toString(), contains('InvalidTimeZoneException'));
      expect(e.toString(), contains('Invalid/Zone'));
      expect(e.toString(), contains('Not found'));
    });
  });

  group('Exception properties', () {
    test('InvalidDateFormatException implements FormatException', () {
      final e = InvalidDateFormatException(
        source: 'src',
        message: 'msg',
        offset: 10,
      );

      expect(e, isA<FormatException>());
      expect(e.source, 'src');
      expect(e.message, 'msg');
      expect(e.offset, 10);
    });

    test('TimeZoneNotInitializedException message property', () {
      final e = TimeZoneNotInitializedException('Custom message');
      expect(e.message, 'Custom message');
    });

    test('InvalidTimeZoneException properties', () {
      final e = InvalidTimeZoneException(
        timeZoneId: 'Asia/Invalid',
        message: 'Zone not found',
      );

      expect(e.timeZoneId, 'Asia/Invalid');
      expect(e.message, 'Zone not found');
    });
  });
}
