library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

typedef ParsePolicyCase = ({
  EasyParseMode mode,
  String input,
  bool shouldPass,
  String id,
});

final parsePolicyCases = <ParsePolicyCase>[
  (
    id: 'iso-z',
    mode: EasyParseMode.legacy,
    input: '2025-12-01T10:30:00Z',
    shouldPass: true,
  ),
  (
    id: 'date-only',
    mode: EasyParseMode.legacy,
    input: '2025-12-01',
    shouldPass: true,
  ),
  (
    id: 'overflow-date',
    mode: EasyParseMode.legacy,
    input: '2025-02-30',
    shouldPass: true,
  ),
  (
    id: 'slash-date',
    mode: EasyParseMode.legacy,
    input: '2025/12/01',
    shouldPass: true,
  ),
  (
    id: 'dot-datetime',
    mode: EasyParseMode.legacy,
    input: '2025.12.01 10:30:00',
    shouldPass: true,
  ),
  (
    id: 'invalid-text',
    mode: EasyParseMode.legacy,
    input: 'not-a-date',
    shouldPass: false,
  ),
  (
    id: 'iso-z',
    mode: EasyParseMode.compatible,
    input: '2025-12-01T10:30:00Z',
    shouldPass: true,
  ),
  (
    id: 'date-only',
    mode: EasyParseMode.compatible,
    input: '2025-12-01',
    shouldPass: true,
  ),
  (
    id: 'overflow-date',
    mode: EasyParseMode.compatible,
    input: '2025-02-30',
    shouldPass: true,
  ),
  (
    id: 'slash-date',
    mode: EasyParseMode.compatible,
    input: '2025/12/01',
    shouldPass: true,
  ),
  (
    id: 'dot-datetime',
    mode: EasyParseMode.compatible,
    input: '2025.12.01 10:30:00',
    shouldPass: true,
  ),
  (
    id: 'invalid-text',
    mode: EasyParseMode.compatible,
    input: 'not-a-date',
    shouldPass: false,
  ),
  (
    id: 'iso-z',
    mode: EasyParseMode.isoStrict,
    input: '2025-12-01T10:30:00Z',
    shouldPass: true,
  ),
  (
    id: 'date-only',
    mode: EasyParseMode.isoStrict,
    input: '2025-12-01',
    shouldPass: true,
  ),
  (
    id: 'overflow-date',
    mode: EasyParseMode.isoStrict,
    input: '2025-02-30',
    shouldPass: false,
  ),
  (
    id: 'slash-date',
    mode: EasyParseMode.isoStrict,
    input: '2025/12/01',
    shouldPass: true,
  ),
  (
    id: 'dot-datetime',
    mode: EasyParseMode.isoStrict,
    input: '2025.12.01 10:30:00',
    shouldPass: true,
  ),
  (
    id: 'invalid-text',
    mode: EasyParseMode.isoStrict,
    input: 'not-a-date',
    shouldPass: false,
  ),
];

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    EasyDateTime.initializeTimeZone();
  });

  group('Parse policy defaults', () {
    test('parse policy matrix includes required baseline coverage', () {
      expect(parsePolicyCases.length, 18);
    });

    test('EasyParseOptions defaults to compatible mode and fixed offsets', () {
      const options = EasyParseOptions();

      expect(options.mode, EasyParseMode.compatible);
      expect(options.offsetResolution, OffsetResolution.fixed);
    });

    test('EasyParseOptions preserves explicit mode and offset resolution', () {
      const options = EasyParseOptions(
        mode: EasyParseMode.isoStrict,
        offsetResolution: OffsetResolution.region,
      );

      expect(options.mode, EasyParseMode.isoStrict);
      expect(options.offsetResolution, OffsetResolution.region);
    });

    test('ParseFailureStage exposes the complete supported stage set', () {
      final stages = ParseFailureStage.values.toSet();

      expect(stages, contains(ParseFailureStage.validation));
      expect(stages, contains(ParseFailureStage.normalization));
      expect(stages, contains(ParseFailureStage.parsing));
      expect(stages, contains(ParseFailureStage.offsetResolution));
      expect(stages, hasLength(4));
    });

    test('strict parse failures expose structured diagnostics', () {
      const options = EasyParseOptions(mode: EasyParseMode.isoStrict);

      expect(
        () => EasyDateTime.parse('2025/02-30', options: options),
        throwsA(
          isA<InvalidDateFormatException>()
              .having(
                (error) => error.diagnostics.mode,
                'diagnostics.mode',
                EasyParseMode.isoStrict,
              )
              .having(
                (error) => error.diagnostics.offsetResolution,
                'diagnostics.offsetResolution',
                OffsetResolution.fixed,
              )
              .having(
                (error) => error.diagnostics.stage,
                'diagnostics.stage',
                ParseFailureStage.validation,
              ),
        ),
      );
    });

    test('normalized fallback failures report normalization stage', () {
      expect(
        () => EasyDateTime.parse('2025/12/01 10:00:00+0A:00'),
        throwsA(
          isA<InvalidDateFormatException>().having(
            (error) => error.diagnostics.stage,
            'diagnostics.stage',
            ParseFailureStage.normalization,
          ),
        ),
      );
    });

    test('plain parse failures report parsing stage', () {
      expect(
        () => EasyDateTime.parse('not-a-date'),
        throwsA(
          isA<InvalidDateFormatException>().having(
            (error) => error.diagnostics.stage,
            'diagnostics.stage',
            ParseFailureStage.parsing,
          ),
        ),
      );
    });

    for (final c in parsePolicyCases) {
      test('mode=${c.mode.name} case=${c.id}', () {
        final result = EasyDateTime.tryParse(
          c.input,
          options: EasyParseOptions(mode: c.mode),
        );
        expect(result != null, c.shouldPass);
      });
    }
  });
}
