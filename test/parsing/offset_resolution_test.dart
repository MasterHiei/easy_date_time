library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('Offset resolution', () {
    test('fixed resolution preserves UTC+08:00 using synthetic UTC names', () {
      final options = EasyParseOptions(
        mode: EasyParseMode.compatible,
        offsetResolution: OffsetResolution.fixed,
      );
      final parsed = EasyDateTime.parse(
        '2025-12-01T10:00:00+08:00',
        options: options,
      );

      expect(parsed.locationName, 'UTC+08:00');
      expect(parsed.timeZoneOffset, const Duration(hours: 8));
      expect(parsed.hour, 10);
      expect(parsed.minute, 0);
    });

    test('const and non-const fixed options behave the same for +05:17', () {
      const constOptions = EasyParseOptions(
        mode: EasyParseMode.compatible,
        offsetResolution: OffsetResolution.fixed,
      );
      final runtimeOptions = EasyParseOptions(
        mode: EasyParseMode.compatible,
        offsetResolution: OffsetResolution.fixed,
      );

      final fromConst = EasyDateTime.parse(
        '2025-12-01T10:00:00+05:17',
        options: constOptions,
      );
      final fromRuntime = EasyDateTime.parse(
        '2025-12-01T10:00:00+05:17',
        options: runtimeOptions,
      );

      expect(fromConst.locationName, fromRuntime.locationName);
      expect(fromConst.locationName, 'UTC+05:17');
      expect(fromConst.timeZoneOffset, fromRuntime.timeZoneOffset);
      expect(
        fromConst.timeZoneOffset,
        const Duration(hours: 5, minutes: 17),
      );
      expect(fromConst.hour, fromRuntime.hour);
      expect(fromConst.hour, 10);
      expect(fromConst.minute, fromRuntime.minute);
      expect(fromConst.minute, 0);
    });

    test('region resolution preserves current IANA lookup behavior', () {
      final parsed = EasyDateTime.parse(
        '2025-12-01T10:00:00+09:00',
        options: const EasyParseOptions(
          offsetResolution: OffsetResolution.region,
        ),
      );

      expect(parsed.locationName, 'Asia/Tokyo');
      expect(parsed.timeZoneOffset, const Duration(hours: 9));
      expect(parsed.hour, 10);
    });

    test('region resolution rejects offsets without an IANA match', () {
      expect(
        () => EasyDateTime.parse(
          '2025-12-01T10:00:00+05:17',
          options: const EasyParseOptions(
            offsetResolution: OffsetResolution.region,
          ),
        ),
        throwsA(isA<InvalidTimeZoneException>()),
      );
    });
  });
}
