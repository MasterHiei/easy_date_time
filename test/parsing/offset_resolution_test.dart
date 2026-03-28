library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('Offset resolution', () {
    test('fixed resolution preserves arbitrary offsets using synthetic UTC names', () {
      final options = EasyParseOptions(
        mode: EasyParseMode.compatible,
        offsetResolution: OffsetResolution.fixed,
      );
      final parsed = EasyDateTime.parse(
        '2025-12-01T10:00:00+05:17',
        options: options,
      );

      expect(parsed.locationName, 'UTC+05:17');
      expect(parsed.timeZoneOffset, const Duration(hours: 5, minutes: 17));
      expect(parsed.hour, 10);
      expect(parsed.minute, 0);
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
