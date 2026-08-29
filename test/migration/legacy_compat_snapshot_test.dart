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
    final endpoints =
        <
          ({
            String name,
            EasyDateTime? Function(EasyParseOptions? options) invoke,
          })
        >[
          (
            name: 'parse',
            invoke: (options) => EasyDateTime.parse(
              '2025-12-01T10:00:00+09:00',
              options: options,
            ),
          ),
          (
            name: 'tryParse',
            invoke: (options) => EasyDateTime.tryParse(
              '2025-12-01T10:00:00+09:00',
              options: options,
            ),
          ),
          (
            name: 'fromIso8601String',
            invoke: (options) => EasyDateTime.fromIso8601String(
              '2025-12-01T10:00:00+09:00',
              options: options,
            ),
          ),
        ];

    for (final endpoint in endpoints) {
      test('default ${endpoint.name} path matches legacy region behavior', () {
        final legacy = endpoint.invoke(
          const EasyParseOptions(mode: EasyParseMode.legacy),
        );
        final current = endpoint.invoke(null);

        expect(current, isNotNull);
        expect(legacy, isNotNull);
        expect(current!.locationName, legacy!.locationName);
        expect(current.timeZoneOffset, legacy.timeZoneOffset);
        expect(current.hour, legacy.hour);
        expect(current.microsecondsSinceEpoch, legacy.microsecondsSinceEpoch);
      });
    }

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

      expect(
        () => EasyDateTime.fromIso8601String('2025-02-30', strict: true),
        throwsFormatException,
      );
      final factoryPermissive = EasyDateTime.fromIso8601String(
        '2025-02-30',
        strict: false,
        options: const EasyParseOptions(mode: EasyParseMode.isoStrict),
      );
      expect(factoryPermissive.month, 3);
      expect(factoryPermissive.day, 2);
    });

    test(
      'default strict callers preserve region failure path for non-IANA offsets',
      () {
        expect(
          () => EasyDateTime.parse('2025-12-01T10:00:00+05:17', strict: false),
          throwsA(
            isA<InvalidTimeZoneException>()
                .having(
                  (error) => error.diagnostics?.mode,
                  'diagnostics.mode',
                  EasyParseMode.compatible,
                )
                .having(
                  (error) => error.diagnostics?.offsetResolution,
                  'diagnostics.offsetResolution',
                  OffsetResolution.region,
                )
                .having(
                  (error) => error.diagnostics?.stage,
                  'diagnostics.stage',
                  ParseFailureStage.offsetResolution,
                ),
          ),
        );
        expect(
          () => EasyDateTime.parse('2025-12-01T10:00:00+05:17', strict: true),
          throwsA(
            isA<InvalidTimeZoneException>()
                .having(
                  (error) => error.diagnostics?.mode,
                  'diagnostics.mode',
                  EasyParseMode.isoStrict,
                )
                .having(
                  (error) => error.diagnostics?.offsetResolution,
                  'diagnostics.offsetResolution',
                  OffsetResolution.region,
                )
                .having(
                  (error) => error.diagnostics?.stage,
                  'diagnostics.stage',
                  ParseFailureStage.offsetResolution,
                ),
          ),
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
