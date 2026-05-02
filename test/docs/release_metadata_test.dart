@TestOn('vm')
library;

import 'dart:io';

import 'package:test/test.dart';

void main() {
  String readFile(String path) =>
      File(path).readAsStringSync().replaceAll('\r\n', '\n');

  String packageVersion() {
    final pubspec = readFile('pubspec.yaml');
    final match = RegExp(
      r'^version:\s+(.+)$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match, isNotNull, reason: 'pubspec.yaml must define a version');

    return match!.group(1)!;
  }

  group('Release metadata', () {
    test('README dependency version matches pubspec version', () {
      final version = packageVersion();
      final readme = readFile('README.md');
      final match = RegExp(
        r'^\s*easy_date_time:\s+\^([0-9]+\.[0-9]+\.[0-9]+)\s*$',
        multiLine: true,
      ).firstMatch(readme);

      expect(match, isNotNull, reason: 'README must show an install version');
      expect(match!.group(1), version);
    });

    test('CHANGELOG top section is unreleased or matches pubspec version', () {
      final version = packageVersion();
      final changelog = readFile('CHANGELOG.md');
      final match = RegExp(
        r'^## \[(.+?)\]',
        multiLine: true,
      ).firstMatch(changelog);

      expect(match, isNotNull, reason: 'CHANGELOG must have a top section');
      expect(match!.group(1), anyOf('Unreleased', version));
    });
  });

  group('README contract', () {
    test('quick-start demonstrates explicit parse options', () {
      final readme = readFile('README.md');

      expect(
        readme,
        contains(
          'final source = EasyDateTime.parse(\n'
          "  '2026-01-18T10:30:00+08:00',\n"
          '  options: const EasyParseOptions(),',
        ),
      );
    });

    test('migration guide uses pub-compatible singular doc path', () {
      final readme = readFile('README.md');
      final changelog = readFile('CHANGELOG.md');

      expect(
        File('doc/migration/v0_12_migration_guide.md').existsSync(),
        isTrue,
        reason: 'migration guide should live under top-level doc/',
      );
      expect(
        readme,
        contains('[Migration guide](doc/migration/v0_12_migration_guide.md)'),
      );
      expect(
        readme,
        contains(
          '[doc/migration/v0_12_migration_guide.md]'
          '(doc/migration/v0_12_migration_guide.md)',
        ),
      );
      expect(changelog, contains('`doc/migration/v0_12_migration_guide.md`'));
    });
  });
}
