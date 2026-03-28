library;

import 'easy_parse_options.dart';

/// Identifies where parsing failed.
enum ParseFailureStage {
  /// Input-level validation failed before `DateTime.parse` ran.
  validation,

  /// Input normalization failed before parsing could continue.
  normalization,

  /// The input reached parsing but could not be parsed successfully.
  parsing,

  /// Offset resolution failed after parsing produced a timestamp.
  offsetResolution,
}

/// Structured metadata attached to parse failures.
final class ParseDiagnostics {
  /// Creates immutable parse diagnostics.
  const ParseDiagnostics({
    required this.mode,
    required this.offsetResolution,
    required this.stage,
  });

  /// The effective parse mode used for the attempt.
  final EasyParseMode mode;

  /// The effective offset resolution policy used for the attempt.
  final OffsetResolution offsetResolution;

  /// The stage where the parse attempt failed.
  final ParseFailureStage stage;
}
