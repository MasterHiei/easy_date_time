# Contributing to easy_date_time

Thank you for considering contributing to easy_date_time! We welcome contributions from the community.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- A clear, descriptive title
- Steps to reproduce the problem
- Expected vs actual behavior
- Your environment (Dart/Flutter version, OS)
- Code samples if applicable

### Suggesting Features

Feature requests are welcome! Please:
- Check existing issues first
- Clearly describe the use case
- Explain why it would be useful
- Consider backward compatibility

### Submitting Pull Requests

1. Fork the repository and create a branch from `main`.
2. Make one focused change with matching tests.
3. Update affected public documentation and examples.
4. Run the relevant verification commands.
5. Submit a PR that explains the behavior change and evidence.

## Development Setup

```bash
# Clone your fork
git clone https://github.com/MasterHiei/easy_date_time.git
cd easy_date_time

# Install dependencies
dart pub get

# Run tests
dart test

# Run analyzer
dart analyze

# Check formatting without rewriting unrelated files
dart format --output=none --set-exit-if-changed .
```

## Code Style

- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines
- Format only the paths you changed when a formatting fix is needed
- Document public APIs and non-obvious constraints where they affect usage
- Keep functions focused and concise
- Add tests for new functionality
- Use descriptive variable and function names

## Verification

Run the narrowest checks that cover the change. CI runs the full coverage and
compatibility matrix.

```bash
# Analyze the package
dart analyze --fatal-infos --fatal-warnings lib test tool

# Run relevant tests; use `dart test` for a full local suite
dart test

# Validate public DartDoc when it changes
dart doc --dry-run .
```

## Commit Message Guidelines

Follow conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type**: feat, fix, docs, style, refactor, test, chore
**Scope**: Optional, e.g., (parser), (timezone)
**Subject**: Clear, imperative mood

Examples:
- `feat(parser): add support for ISO 8601 basic format`
- `fix: handle leap year edge cases correctly`
- `docs: improve timezone handling guide`

## CI Checks

Wait for `Required CI` to pass before merging a pull request to `main`. It
covers package and example checks, VM and Chrome tests, and at least 95% line
coverage in `lib/`. Compatibility tests run on Dart 3.10.0 with the lowest
resolvable versions of `meta` and `timezone`, and on Dart stable on macOS and
Windows.

`Dart Beta` runs separately on `main` to catch issues with the next SDK.

## Testing

- Write focused tests for changed behavior
- Ensure tests are deterministic and fast
- Test edge cases and error conditions
- Use descriptive test names that state the observable behavior

Example test structure:

```dart
test('should parse ISO 8601 date with timezone offset', () {
  // Arrange
  final dateString = '2025-12-01T10:30:00+09:00';

  // Act
  final result = EasyDateTime.parse(dateString);

  // Assert
  expect(result.year, 2025);
  expect(result.month, 12);
  expect(result.location.name, 'Asia/Tokyo');
});
```

## Documentation

- Use DartDoc for public API behavior, constraints, and exceptions
- Include examples when they make an API easier to use correctly
- Update README.md, migration guides, and examples when their promised behavior changes
- Keep examples simple, clear, and compilable or runnable
- Follow the ownership and generated-document rules in [doc/README.md](doc/README.md)

Release maintainers update [CHANGELOG.md](CHANGELOG.md) when preparing a
release with user-visible changes.

## Testing Timezone Code

Special considerations when testing timezone-dependent code:

```dart
setUpAll(() {
  EasyDateTime.initializeTimeZone();
  // Save original default location
  _originalDefault = EasyDateTime.getDefaultLocation();
});

tearDown(() {
  // Restore original default location
  if (_originalDefault != null) {
    EasyDateTime.setDefaultLocation(_originalDefault);
  } else {
    EasyDateTime.clearDefaultLocation();
  }
});
```

## Questions?

Feel free to open an issue for clarification or discussion!
