# easy_date_time

**Dart 向けタイムゾーン対応日時ライブラリ**

IANA タイムゾーンを完全にサポートし、Dart 標準の `DateTime` だけでは難しいタイムゾーン処理を直感的に行えるように設計されています。暗黙的な UTC 変換を行わず、解析された日時情報を正確に保持します。

[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)

**[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md)** | **[中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md)**

---

## なぜ easy_date_time なのか？

Dart 標準の `DateTime` や既存のライブラリは、複雑なタイムゾーン処理においていくつかの制限がありました。

| 既存のソリューション | 利点 | 課題 | 本ライブラリのアプローチ |
| --- | --- | --- | --- |
| **DateTime** (標準) | 公式、依存なし | オフセットが自動的に UTC/Local に変換され、**タイムゾーン情報が失われる** | **値の保持**: 解析した日時とオフセットをそのまま保持します。 |
| **timezone** | IANA 完全対応 | API が複雑で、タイムゾーン文字列の検索が必要 | **使いやすさ**: 一般的なタイムゾーンを定数として提供しています。 |
| **intl** | 強力なフォーマット機能 | 主に表示用であり、日時計算機能が不足している | **役割の分離**: 計算と操作に特化し、表示は intl と連携可能です。 |
| **flutter_native_timezone** | システム設定の取得 | 取得のみで、計算機能はない | **包括的**: 解析、計算、変換をワンストップで提供します。 |

**比較:**

```dart
// DateTime: オフセットは解析されますが、UTC に変換されるため時間が変わります
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2 (文脈が失われる)

// EasyDateTime: 入力された時間をそのまま保持します
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10 (期待通り)
```

---

## 主な特徴

* 🌍 **完全な IANA タイムゾーン対応**
  `Asia/Shanghai` や `America/New_York` など、すべての IANA タイムゾーンをシンプルな API でサポートします。

* 🕒 **解析値を維持**
  意図しない UTC への暗黙変換は行いません。解析した時間がそのまま保持されます。

* ➕ **直感的な日時演算**
  `now + 1.days` や `2.hours` のような自然な記述で計算が可能です。

* 🔄 **明示的な変換**
  `.inLocation()` または `.toUtc()` を呼び出した場合のみ、タイムゾーンの変換が行われます。

* 🧱 **安全な日付操作**
  月末の計算（例: 1月31日 + 1ヶ月 -> 2月28日）などを `copyWithClamped` で安全に処理します。

---

## インストール

`pubspec.yaml` に以下を追加してください：

```yaml
dependencies:
  easy_date_time: ^0.2.0
```

**注意**: 正確な計算を行うため、アプリ起動時に**必ず**タイムゾーンデータベースの初期化を行ってください。

```dart
void main() {
  initializeTimeZone();  // 必須

  // オプション: デフォルトのタイムゾーンを設定
  setDefaultLocation(TimeZones.shanghai);

  runApp(MyApp());
}
```

---

## クイックスタート

```dart
final now = EasyDateTime.now();  // デフォルトまたはローカルタイムゾーン
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final parsed = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(parsed.hour);  // 10
```

---

## タイムゾーンの利用

### 1. 一般的なタイムゾーン（推奨）

頻繁に使用されるタイムゾーンは定数として用意されています。

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
```

### 2. その他の IANA タイムゾーン

標準的な IANA 文字列も使用可能です。

```dart
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
```

### 3. グローバルデフォルトの設定

デフォルトを設定することで、`EasyDateTime.now()` が常にそのタイムゾーンを使用するようになります。

```dart
setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // Asia/Shanghai として扱われます
```

---

## 時間情報の保持

オフセット付きの文字列を解析しても、`EasyDateTime` はそのリテラル時間と場所の両方を保持します。

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10
print(dt.locationName);  // Asia/Shanghai
```

変換が必要な場合は、明示的にメソッドを呼び出してください。

```dart
final ny = dt.inLocation(TimeZones.newYork);
final utc = dt.toUtc();
```

---

## タイムゾーン変換

異なるタイムゾーン間での「同じ瞬間」の比較：

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final newYork = tokyo.inLocation(TimeZones.newYork);

print(tokyo.isAtSameMomentAs(newYork)); // true: 絶対時間は同じです
```

---

## 日時演算

```dart
final now = EasyDateTime.now();
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
```

### 月末のオーバーフロー処理

`EasyDateTime` は月をまたぐ計算を安全に処理します。

```dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // 3月3日 (通常のオーバーフロー挙動)
jan31.copyWithClamped(month: 2); // 2月28日 (月末にクランプ)
```

---

## 拡張機能の競合回避

本パッケージは `int` 型への拡張（`1.days` 等）を含んでいます。他パッケージと競合する場合は、`hide` を使用して回避できます。

```dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
```

---

## JSON シリアライズ

`json_serializable` や `freezed` と互換性があり、カスタムコンバーターを利用できます。

```dart
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}
```

---

## 注意事項

* `==` 演算子は、タイムゾーンに関わらず**絶対時間（Instant）**の等価性を判定します。
* 有効な IANA タイムゾーンオフセットのみがサポートされます。非標準のオフセットはエラーとなります。
* 使用前に `initializeTimeZone()` の呼び出しが必要です。

### 安全な解析

ユーザー入力を解析する場合は、`tryParse` の使用を推奨します。

```dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  print('無効な日付形式です');
}
```

---

## 貢献

Issue や Pull Request を歓迎します。
詳細は [CONTRIBUTING.md](CONTRIBUTING.md) をご覧ください。

---

## ライセンス

BSD 2-Clause
