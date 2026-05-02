# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md) | [中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md)

`DateTime` 互換 API と IANA タイムゾーンサポートを提供するライブラリです。

## Why easy_date_time

`DateTime.parse()` はオフセット付き入力を UTC に正規化するため、壁時計の時刻が変わることがあります。
`EasyDateTime.parse()` は元のローカル時刻コンテキストを保持します。

```dart
DateTime.parse('2026-01-18T10:30:00+08:00').hour;   // 2
EasyDateTime.parse('2026-01-18T10:30:00+08:00').hour; // 10
```

## Quick Start

### 1) 依存関係を追加

```yaml
dependencies:
  easy_date_time: ^0.12.0
```

### 2) タイムゾーン DB を 1 回初期化

```dart
import 'package:easy_date_time/easy_date_time.dart';

void main() {
  EasyDateTime.initializeTimeZone();
}
```

### 3) 解析と変換

```dart
final source = EasyDateTime.parse('2026-01-18T10:30:00+08:00');
final ny = source.inLocation(TimeZones.newYork);

print(source.hour);         // 10
print(source.locationName); // UTC+08:00 (fixed が既定)
print(ny.locationName);     // America/New_York
```

## Core Concepts

- `EasyDateTime` は `DateTime` を実装。
- 解析ポリシーは `EasyParseOptions` で明示。
- options を明示した場合の既定は `compatible + fixed`。
- 移行互換のため、legacy の no-options 経路を保持。

```dart
final dt = EasyDateTime.parse(
  '2026-01-18T10:30:00+08:00',
  options: const EasyParseOptions(
    mode: EasyParseMode.compatible,
    offsetResolution: OffsetResolution.fixed,
  ),
);
```

## Common Tasks

### タイムゾーン付き生成

```dart
final nowInTokyo = EasyDateTime.now(location: TimeZones.tokyo);
final meeting = EasyDateTime(2026, 5, 3, 9, 30, location: TimeZones.london);
```

### DST セーフな日付演算

```dart
final ny = TimeZones.newYork;
final beforeDst = EasyDateTime(2025, 3, 9, 0, 0, location: ny);

final wallClock = beforeDst.addCalendarDays(1); // 2025-03-10 00:00
final physical = beforeDst.add(const Duration(days: 1)); // 2025-03-10 01:00
```

### フォーマット

```dart
final formatted = EasyDateTime.now(location: TimeZones.tokyo)
    .format('yyyy-MM-dd HH:mm:ss xxxxx');
```

## Migration Guide (v0.12)

詳細: [docs/migration/v0_12_migration_guide.md](docs/migration/v0_12_migration_guide.md)

### `strict` から `options` へ

- `strict: false` -> `EasyParseOptions(mode: EasyParseMode.compatible)`
- `strict: true` -> `EasyParseOptions(mode: EasyParseMode.isoStrict)`

### オフセット解決

- 互換/legacy 経路: オフセットから地域タイムゾーン推論（`OffsetResolution.region`）
- 明示的新経路: 固定オフセットロケーション（`OffsetResolution.fixed`、例 `UTC+08:00`）

## DateTime / timezone API Mapping

| 既存 API | easy_date_time |
|---|---|
| `DateTime.now()` | `EasyDateTime.now()` |
| `DateTime.utc(...)` | `EasyDateTime.utc(...)` |
| `DateTime.parse(String)` | `EasyDateTime.parse(String, options: ...)` |
| `DateTime.tryParse(String)` | `EasyDateTime.tryParse(String, options: ...)` |
| `DateTime.fromMillisecondsSinceEpoch(ms)` | `EasyDateTime.fromMillisecondsSinceEpoch(ms)` |
| `DateTime.toUtc()` | `EasyDateTime.toUtc()` |
| `DateTime.toLocal()` | `EasyDateTime.toLocal()` |
| `DateTime` に IANA Location モデルなし | `inLocation(TimeZones.xxx)` |
| なし | `setDefaultLocation(...)` / `clearDefaultLocation()` |

## FAQ

### `intl` と併用できますか？

できます。`EasyDateTime` は `DateTime` 実装なので既存フォーマッタで利用可能です。

### 既定で strict ですか？

いいえ。厳密検証が必要な場合は `EasyParseMode.isoStrict` を使ってください。

### タイムゾーン初期化は必須ですか？

はい。タイムゾーン機能を使う前に `EasyDateTime.initializeTimeZone()` を呼び出してください。
