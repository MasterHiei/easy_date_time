/// Parsing behavior modes for [EasyDateTime] string parsing.
enum EasyParseMode {
  /// Preserve the legacy parsing behavior.
  legacy,

  /// Preserve the current permissive parsing behavior.
  compatible,

  /// Apply strict calendar validation with consistent date separators.
  ///
  /// This mode is not limited to ISO 8601 input.
  isoStrict,
}

/// How timezone offsets should be resolved during parsing.
enum OffsetResolution {
  /// Preserve the numeric offset as a synthetic `UTC±HH:MM` location.
  fixed,

  /// Infer an IANA region from the numeric offset when possible.
  region,
}

/// Configures how [EasyDateTime] parsing should behave.
final class EasyParseOptions {
  /// Creates parsing options.
  const EasyParseOptions({
    this.mode = EasyParseMode.compatible,
    this.offsetResolution = OffsetResolution.fixed,
  });

  /// Parsing mode to use.
  final EasyParseMode mode;

  /// How timezone offsets should be resolved.
  final OffsetResolution offsetResolution;
}
