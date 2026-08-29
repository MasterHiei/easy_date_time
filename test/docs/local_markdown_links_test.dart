@TestOn('vm')
library;

import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('Local Markdown links', () {
    test('resolve relative to their source document', () {
      final result = Process.runSync('git', ['ls-files', '--', '*.md']);

      expect(result.exitCode, 0, reason: result.stderr.toString());

      final missingTargets = <String>[];
      final markdownFiles = result.stdout
          .toString()
          .split('\n')
          .where((path) => path.isNotEmpty && !path.startsWith('doc/api/'));

      for (final path in markdownFiles) {
        final document = File(path);
        final links = RegExp(
          r'\]\((?:<)?([^\s>)]+)',
        ).allMatches(document.readAsStringSync());

        for (final link in links) {
          final target = link.group(1)!;
          if (_isExternalOrAnchor(target)) {
            continue;
          }

          final localTarget = target.split(RegExp(r'[?#]')).first;
          final resolved = File('${document.parent.path}/$localTarget');
          if (!resolved.existsSync()) {
            missingTargets.add('$path -> $target');
          }
        }
      }

      expect(missingTargets, isEmpty, reason: missingTargets.join('\n'));
    });
  });
}

bool _isExternalOrAnchor(String target) =>
    target.startsWith('#') ||
    target.startsWith('//') ||
    RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(target);
