# Contributing to easy_date_time

Thank you for considering contributing to easy_date_time! We welcome contributions from the community.

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please be respectful and constructive in all interactions.

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

1. **Fork the repository** and create your branch from `main`
2. **Write tests** for your changes
3. **Follow the code style** - run `dart analyze` and `dart format`
4. **Update documentation** if you're changing APIs
5. **Add a changelog entry** in CHANGELOG.md under `[Unreleased]`
6. **Ensure tests pass** - run `dart test`
7. **Submit your PR** with a clear description

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

# Format code
dart format .
```

## Code Style

- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines
- Use `dart format` for consistent formatting
- Write clear, descriptive comments for public APIs
- Keep functions focused and concise
- Add tests for new functionality
- Use descriptive variable and function names

## Pre-commit Checks

Before committing, ensure:

```bash
# 1. Format code
dart format .

# 2. Run analyzer
dart analyze --fatal-infos

# 3. Run all tests
dart test

# 4. Check test coverage
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

# (Coverage should be >= 90%)
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

### CI Checks
When you open a Pull Request, the following automated checks will run:
1.  **Analyze**: Static analysis with `dart analyze --fatal-infos`.
2.  **Test (Stable & Coverage)**: Runs all tests on the stable SDK and reports code coverage (uploading to Codecov).
3.  **Test Compatibility**: Runs tests on the oldest supported SDK (`3.0.0`) and the latest `beta` to ensure backward and forward compatibility.

All checks must pass before merging.

## Testing

- Write unit tests for all new features
- Ensure tests are deterministic and fast
- Test edge cases and error conditions
- Maintain high test coverage (>= 80%)
- Use descriptive test names: `test('should_action_when_condition')`

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

- Use dartdoc comments (`///`) for all public APIs
- Include code examples in documentation
- Update README.md for new features
- Keep examples simple and clear
- Document breaking changes in CHANGELOG.md
- Update relevant guides in `docs/` if present

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

## Reporting Security Issues

Do not open public issues for security vulnerabilities. Instead, email security concerns to the maintainers directly.

## Questions?

Feel free to open an issue for clarification or discussion!
