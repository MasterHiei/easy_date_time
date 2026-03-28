library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  group('Parse policy defaults', () {
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
  });
}
