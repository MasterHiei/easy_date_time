library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  tearDown(() {
    EasyDateTime.clearDefaultLocation();
  });

  test('README quick-start parse sample remains valid', () {
    final dt = EasyDateTime.parse(
      '2026-01-18T10:30:00+08:00',
      options: const EasyParseOptions(),
    );

    expect(dt.hour, 10);
    expect(dt.locationName, 'UTC+08:00');
  });

  test('README parse options sample keeps fixed offset location', () {
    final dt = EasyDateTime.parse(
      '2026-01-18T10:30:00+08:00',
      options: const EasyParseOptions(
        mode: EasyParseMode.compatible,
        offsetResolution: OffsetResolution.fixed,
      ),
    );

    expect(dt.locationName, 'UTC+08:00');
  });

  test('README migration mapping strict true equals isoStrict mode', () {
    final legacyStrict = EasyDateTime.tryParse('2026-02-30', strict: true);
    final optionsStrict = EasyDateTime.tryParse(
      '2026-02-30',
      options: const EasyParseOptions(mode: EasyParseMode.isoStrict),
    );

    expect(legacyStrict, isNull);
    expect(optionsStrict, isNull);
  });
}
