// ignore_for_file: deprecated_member_use_from_same_package

library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('Legacy compatibility snapshot', () {
    test('default parse path matches legacy region-based behavior', () {
      const input = '2025-12-01T10:00:00+09:00';

      final legacy = EasyDateTime.parse(
        input,
        options: const EasyParseOptions(mode: EasyParseMode.legacy),
      );
      final current = EasyDateTime.parse(input);

      expect(current.locationName, legacy.locationName);
      expect(current.timeZoneOffset, legacy.timeZoneOffset);
      expect(current.hour, legacy.hour);
      expect(current.microsecondsSinceEpoch, legacy.microsecondsSinceEpoch);
    });

    test('default tryParse path matches legacy region-based behavior', () {
      const input = '2025-12-01T10:00:00-05:00';

      final legacy = EasyDateTime.tryParse(
        input,
        options: const EasyParseOptions(mode: EasyParseMode.legacy),
      );
      final current = EasyDateTime.tryParse(input);

      expect(current, isNotNull);
      expect(legacy, isNotNull);
      expect(current!.locationName, legacy!.locationName);
      expect(current.timeZoneOffset, legacy.timeZoneOffset);
      expect(current.hour, legacy.hour);
      expect(current.microsecondsSinceEpoch, legacy.microsecondsSinceEpoch);
    });

    test('strict overrides options mode mapping for parse and tryParse', () {
      expect(
        () => EasyDateTime.parse(
          '2025-02-30',
          strict: true,
          options: const EasyParseOptions(mode: EasyParseMode.legacy),
        ),
        throwsFormatException,
      );

      final permissive = EasyDateTime.parse(
        '2025-02-30',
        strict: false,
        options: const EasyParseOptions(mode: EasyParseMode.isoStrict),
      );

      expect(permissive.month, 3);
      expect(permissive.day, 2);
      expect(
        EasyDateTime.tryParse(
          '2025-02-30',
          strict: true,
          options: const EasyParseOptions(mode: EasyParseMode.legacy),
        ),
        isNull,
      );
    });

    test(
      'default strict callers preserve region failure path for non-IANA offsets',
      () {
        expect(
          () => EasyDateTime.parse('2025-12-01T10:00:00+05:17', strict: false),
          throwsA(isA<InvalidTimeZoneException>()),
        );
        expect(
          () => EasyDateTime.parse('2025-12-01T10:00:00+05:17', strict: true),
          throwsA(isA<InvalidTimeZoneException>()),
        );

        expect(
          EasyDateTime.tryParse('2025-12-01T10:00:00+05:17', strict: false),
          isNull,
        );
        expect(
          EasyDateTime.tryParse('2025-12-01T10:00:00+05:17', strict: true),
          isNull,
        );
      },
    );
  });
}
