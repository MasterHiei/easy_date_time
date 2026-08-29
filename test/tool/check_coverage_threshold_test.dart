@TestOn('vm')
library;

import 'dart:io';

import 'package:test/test.dart';

import '../../tool/check_coverage_threshold.dart' as coverage;

void main() {
  group('check_coverage_threshold', () {
    test('reports a missing LCOV file', () {
      final directory = Directory.systemTemp.createTempSync(
        'easy_date_time_coverage_test_',
      );
      addTearDown(() => directory.deleteSync(recursive: true));

      final result = coverage.checkCoverage([
        '${directory.path}/missing.info',
        '95',
      ]);

      expect(result.exitCode, 66);
      expect(result.standardError, contains('Coverage file not found'));
    });

    test('rejects a report without executable library lines', () {
      final report = _writeReport('SF:test/example_test.dart\nDA:1,1\n');

      final result = coverage.checkCoverage([report.path, '95']);

      expect(result.exitCode, 65);
      expect(result.standardError, contains('no executable lib/ source lines'));
    });

    test('counts only lib/ source lines', () {
      final report = _writeReport('''
SF:test/example_test.dart
DA:1,1
end_of_record
SF:/another-package/lib/example.dart
DA:1,1
end_of_record
SF:/pub-cache/hosted/example/lib/example.dart
DA:1,1
end_of_record
SF:lib/example.dart
DA:1,0
end_of_record
''');

      final result = coverage.checkCoverage([report.path, '95']);

      expect(result.exitCode, 1);
      expect(result.standardOutput, contains('Line coverage: 0.00%'));
      expect(result.standardError, contains('Coverage gate failed'));
    });

    test('rejects library coverage below the requested threshold', () {
      final report = _writeReport('''
SF:${Directory.current.path}/lib/example.dart
DA:1,1
DA:2,0
end_of_record
''');

      final result = coverage.checkCoverage([report.path, '75']);

      expect(result.exitCode, 1);
      expect(result.standardOutput, contains('Line coverage: 50.00%'));
      expect(result.standardError, contains('Coverage gate failed'));
    });

    test('accepts library coverage that reaches the requested threshold', () {
      final report = _writeReport('''
SF:lib/example.dart
DA:1,1
DA:2,2
end_of_record
''');

      final result = coverage.checkCoverage([report.path, '95']);

      expect(result.exitCode, 0);
      expect(result.standardOutput, contains('Line coverage: 100.00%'));
      expect(result.standardOutput, contains('threshold: 95.00%'));
    });

    test('CLI forwards the result to the process exit code and output', () {
      final report = _writeReport('''
SF:lib/example.dart
DA:1,1
end_of_record
''');

      final result = _runCheck(report.path, '95');

      expect(result.exitCode, 0);
      expect(result.stdout, contains('Line coverage: 100.00%'));
      expect(result.stderr, isEmpty);
    });
  });
}

File _writeReport(String contents) {
  final directory = Directory.systemTemp.createTempSync(
    'easy_date_time_coverage_test_',
  );
  addTearDown(() => directory.deleteSync(recursive: true));
  final report = File('${directory.path}/coverage.info');
  report.writeAsStringSync(contents);
  return report;
}

ProcessResult _runCheck(String reportPath, String threshold) => Process.runSync(
  Platform.resolvedExecutable,
  ['run', 'tool/check_coverage_threshold.dart', reportPath, threshold],
);
