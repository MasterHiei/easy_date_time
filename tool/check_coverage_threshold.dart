import 'dart:io';

void main(List<String> args) {
  final result = checkCoverage(args);
  stdout.write(result.standardOutput);
  stderr.write(result.standardError);
  exitCode = result.exitCode;
}

/// Result of evaluating an LCOV report against a line-coverage threshold.
final class CoverageCheckResult {
  const CoverageCheckResult({
    required this.exitCode,
    this.standardOutput = '',
    this.standardError = '',
  });

  final int exitCode;
  final String standardOutput;
  final String standardError;
}

/// Evaluates the coverage CLI [args] without terminating the current process.
CoverageCheckResult checkCoverage(
  List<String> args, {
  Directory? currentDirectory,
}) {
  if (args.length != 2) {
    return const CoverageCheckResult(
      exitCode: 64,
      standardError:
          'Usage: dart run tool/check_coverage_threshold.dart '
          '<lcov-file> <min-percent>\n',
    );
  }

  final file = File(args[0]);
  if (!file.existsSync()) {
    return CoverageCheckResult(
      exitCode: 66,
      standardError: 'Coverage file not found: ${args[0]}\n',
    );
  }

  final min = double.parse(args[1]);
  final lines = file.readAsLinesSync();
  final packageRoot = currentDirectory ?? Directory.current;
  final packageLibPath = '${packageRoot.absolute.path}/lib'.replaceAll(
    '\\',
    '/',
  );

  var found = 0;
  var hit = 0;
  var isLibrarySource = false;
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      isLibrarySource = _isLibrarySource(line.substring(3), packageLibPath);
      continue;
    }

    if (!isLibrarySource) {
      continue;
    }

    if (!line.startsWith('DA:')) {
      continue;
    }

    found++;
    final count = int.parse(line.split(',')[1]);
    if (count > 0) {
      hit++;
    }
  }

  if (found == 0) {
    return const CoverageCheckResult(
      exitCode: 65,
      standardError:
          'Coverage report contains no executable lib/ source lines.\n',
    );
  }

  final percent = hit * 100.0 / found;
  final summary =
      'Line coverage: ${percent.toStringAsFixed(2)}% '
      '(threshold: ${min.toStringAsFixed(2)}%)\n';

  if (percent < min) {
    return CoverageCheckResult(
      exitCode: 1,
      standardOutput: summary,
      standardError: 'Coverage gate failed.\n',
    );
  }

  return CoverageCheckResult(exitCode: 0, standardOutput: summary);
}

bool _isLibrarySource(String sourcePath, String packageLibPath) {
  final normalized = sourcePath.replaceAll('\\', '/');
  return normalized.startsWith('lib/') ||
      normalized.startsWith('$packageLibPath/');
}
