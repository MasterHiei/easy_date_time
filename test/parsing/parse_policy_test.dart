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
  });
}
