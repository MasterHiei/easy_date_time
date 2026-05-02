import 'dart:io';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
      'Usage: dart run tool/check_coverage_threshold.dart <lcov-file> <min-percent>',
    );
    exit(64);
  }

  final file = File(args[0]);
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: ${args[0]}');
    exit(66);
  }

  final min = double.parse(args[1]);
  final lines = file.readAsLinesSync();

  var found = 0;
  var hit = 0;
  for (final line in lines) {
    if (!line.startsWith('DA:')) {
      continue;
    }

    found++;
    final count = int.parse(line.split(',')[1]);
    if (count > 0) {
      hit++;
    }
  }

  final percent = found == 0 ? 0.0 : (hit * 100.0 / found);
  stdout.writeln(
    'Line coverage: ${percent.toStringAsFixed(2)}% (threshold: ${min.toStringAsFixed(2)}%)',
  );

  if (percent < min) {
    stderr.writeln('Coverage gate failed.');
    exit(1);
  }
}
