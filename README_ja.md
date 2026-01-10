# easy_date_time

**Dart 向けタイムゾーン対応日時ライブラリ**

IANA タイムゾーンデータベースを完全にサポートし、Dart 標準の `DateTime` だけでは難しいタイムゾーン処理を直感的に扱えます。**不変（Immutable）** であり、意図しない UTC 変換を行わず、解析された日時情報を正確に保持します。

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)


**[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md)** | **[中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md)**

---

## なぜ easy_date_time なのか？

Dart の `DateTime` は UTC とローカル時間のみをサポートします。本ライブラリは完全な IANA タイムゾーンサポートを追加し、`DateTime` の直接的な代替として機能します。

### 他の日時パッケージとの比較

| 機能 | `DateTime` | `timezone` | `easy_date_time` |
|------|:----------:|:----------:|:----------------:|
| **IANA タイムゾーン** | ❌ | ✅ | ✅ |
| **不変性 (Immutable)** | ✅ | ✅ | ✅ |
| **API インターフェース** | 標準 | `extends DateTime` | `implements DateTime` |
| **タイムゾーン検索** | N/A | 手動 (`getLocation`) | 定数 / 自動キャッシュ |

### API 設計の比較

**`timezone` パッケージ:**
```dart
import 'package:timezone/timezone.dart' as tz;
// 手動で location オブジェクトを取得する必要がある
final detroit = tz.getLocation('America/Detroit');
final now = tz.TZDateTime.now(detroit);
```

**`easy_date_time`:**
```dart
// 静的定数またはキャッシュされた検索を使用
final now = EasyDateTime.now(location: TimeZones.detroit);
```

### DateTime vs EasyDateTime

```dart
// DateTime: オフセット → UTC（時間が変わる）
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2

// EasyDateTime: 時間を保持
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10
```

| 機能 | DateTime | EasyDateTime |
|---|----------|--------------|
| **タイムゾーン対応** | UTC / システムローカル | IANA データベース |
| **解析時の挙動** | **正規化** (UTCへ変換) | **保持** (オフセット/時間を維持) |
| **型関係** | 基底クラス | `implements DateTime` |
| **混在利用** | N/A | ⚠️ `hashCode` が異なる |

---

## 主な特徴

### 🌍 完全な IANA タイムゾーン対応
標準 IANA 定数またはカスタム文字列を使用。
```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
```

### 🕒 無損失な解析
暗黙的な UTC 変換なし。解析された日時値とタイムゾーン情報を正確に保持。
```dart
EasyDateTime.parse('2025-12-07T10:00+08:00').hour // -> 10
```

### ➕ 直感的な日時演算
直感的な日付時間計算構文。
```dart
final later = now + 2.hours + 30.minutes;
```

### 🧱 安全な日付計算
月のオーバーフローなどの境界ケースを自動的に処理。
```dart
jan31.copyWithClamped(month: 2); // -> 2月28日
```

### 📝 柔軟な日時フォーマット
カスタムパターンとプリコンパイルによる最適化をサポート。
```dart
dt.format('yyyy-MM-dd'); // -> 2025-12-07
```

---

## インストール

`pubspec.yaml` に以下を追加してください：

```yaml
dependencies:
  easy_date_time: ^0.8.0
```

**注意**: 正確な計算を行うため、アプリ起動時に**必ず**タイムゾーンデータベースの初期化を行ってください。

```dart
void main() {
  EasyDateTime.initializeTimeZone();  // 必須

  // オプション: デフォルトのタイムゾーンを設定
  EasyDateTime.setDefaultLocation(TimeZones.shanghai);

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

よく使うタイムゾーンは定数で利用できます。

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
```

### 2. その他の IANA タイムゾーン

標準的な IANA 文字列を使って指定することも可能です。

```dart
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
```

### 3. グローバルデフォルトの設定

デフォルトを設定すると、`EasyDateTime.now()` は常にそのタイムゾーンを使用します。

```dart
EasyDateTime.setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // Asia/Shanghai として扱われます
```

---

## タイムゾーン処理

解析時、`EasyDateTime` は時間と場所の情報をそのまま保持します：

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10 (UTC に変換されずそのまま保持)
print(dt.locationName);  // Asia/Shanghai
```

### タイムゾーン変換

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final newYork = tokyo.inLocation(TimeZones.newYork);
final utc = tokyo.toUtc();

tokyo.isAtSameMomentAs(newYork);  // true: 絶対時間は同じ
```

---

## 日時演算

```dart
final now = EasyDateTime.now();
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
```

### カレンダー日演算（サマータイム対応）

時刻を維持したまま日付を操作する場合（DST 切り替え時に重要）：

```dart
final dt = EasyDateTime(2025, 3, 9, 0, 0, location: newYork); // DST 切り替え日

dt.addCalendarDays(1);       // 2025-03-10 00:00 ✓ (同じ時刻)
dt.add(Duration(days: 1));   // 2025-03-10 01:00   (24時間後、時刻がずれる)
```

`tomorrow` と `yesterday` もカレンダー日の考え方を使用します：

```dart
dt.tomorrow;   // addCalendarDays(1) と同等
dt.yesterday;  // subtractCalendarDays(1) と同等
```

### 月末のオーバーフロー処理

`EasyDateTime` は月をまたぐ計算を安全に処理します。

```dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // ⚠️ 3月3日 (通常のオーバーフロー)
jan31.copyWithClamped(month: 2); // ✅ 2月28日 (月末にクランプ)
```

### 時間単位の境界

日時を指定した時間単位の境界に切り詰めます：

```dart
final dt = EasyDateTime(2025, 6, 18, 14, 30, 45); // 水曜日

dt.startOf(DateTimeUnit.day);   // 2025-06-18 00:00:00
dt.startOf(DateTimeUnit.week);  // 2025-06-16 00:00:00 (月曜日)
dt.startOf(DateTimeUnit.month); // 2025-06-01 00:00:00

dt.endOf(DateTimeUnit.day);     // 2025-06-18 23:59:59.999999
dt.endOf(DateTimeUnit.week);    // 2025-06-22 23:59:59.999999 (日曜日)
dt.endOf(DateTimeUnit.month);   // 2025-06-30 23:59:59.999999
```

> 週の境界は ISO 8601 に準拠（月曜日 = 週の最初の日）。

---

## intl との連携

ロケール対応フォーマット（例: "January" → "1月"）には `intl` パッケージと組み合わせて使用します：

```dart
import 'package:intl/intl.dart';
import 'package:easy_date_time/easy_date_time.dart';

final dt = EasyDateTime.now(location: TimeZones.tokyo);

// intl でロケール対応フォーマット
DateFormat.yMMMMd('ja').format(dt);  // '2025年12月20日'
DateFormat.yMMMMd('en').format(dt);  // 'December 20, 2025'
```

> **注**: `EasyDateTime` は `DateTime` インターフェースを実装しているため、`DateFormat.format()` で直接使用可能。

---

## 日時フォーマット

`format()` メソッドで柔軟な日時フォーマットが可能です：

```dart
final dt = EasyDateTime(2025, 12, 1, 14, 30, 45);

dt.format('yyyy-MM-dd');           // '2025-12-01'
dt.format('yyyy/MM/dd HH:mm:ss');  // '2025/12/01 14:30:45'
dt.format('MM/dd/yyyy');           // '12/01/2025'
dt.format('hh:mm a');              // '02:30 PM'
```

> [!TIP]
> **パフォーマンス最適化**: ループ処理などでは `EasyDateTimeFormatter` でパターンを事前コンパイルしてください。
> ```dart
> // 一度コンパイルして再利用
> static final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');
> String result = formatter.format(date);
> ```

### 定義済みフォーマット

`DateTimeFormats` で一般的なパターンを使用できます：

```dart
dt.format(DateTimeFormats.isoDate);      // '2025-12-01'
dt.format(DateTimeFormats.isoTime);      // '14:30:45'
dt.format(DateTimeFormats.isoDateTime);  // '2025-12-01T14:30:45'
dt.format(DateTimeFormats.time12Hour);   // '02:30 PM'
dt.format(DateTimeFormats.time24Hour);   // '14:30'
dt.format(DateTimeFormats.rfc2822);      // 'Mon, 01 Dec 2025 14:30:45 +0800'
```

### 日付プロパティ

よく使う日付の判定・計算プロパティ：

~~~dart
final dt = EasyDateTime(2024, 6, 15);

// 年間関連
dt.dayOfYear;    // 167（年間の通算日）
dt.weekOfYear;   // 24（年間の週番号、ISO 8601 準拠）
dt.quarter;      // 2（四半期）
dt.isLeapYear;   // true（うるう年かどうか）

// 月間関連
dt.daysInMonth;  // 30（当月の日数）

// 週末判定
final saturday = EasyDateTime(2025, 1, 4);
saturday.isWeekend;  // true（週末かどうか）
saturday.isWeekday;  // false（平日かどうか）

// 時間クエリ
final past = EasyDateTime(2020, 1, 1);
past.isPast;       // true（過去かどうか）
past.isFuture;     // false（未来かどうか）

final now = EasyDateTime.now();
now.isThisWeek;    // true（今週かどうか）
now.isThisMonth;   // true（今月かどうか）
now.isThisYear;    // true（今年かどうか）

// サマータイム検出
final nyJuly = EasyDateTime(2025, 7, 15, location: TimeZones.newYork);
nyJuly.isDst;      // true（サマータイム適用中）
~~~

| プロパティ | 説明 | 値の範囲 |
|------------|------|----------|
| `dayOfYear` | 年間の通算日 | 1-366 |
| `weekOfYear` | 年間の週番号（ISO 8601） | 1-53 |
| `quarter` | 四半期 | 1-4 |
| `daysInMonth` | 当月の日数 | 28/29/30/31 |
| `isLeapYear` | うるう年かどうか | true/false |
| `isWeekend` | 週末かどうか（土曜・日曜） | true/false |
| `isWeekday` | 平日かどうか（月曜〜金曜） | true/false |
| `isPast` | 過去かどうか | true/false |
| `isFuture` | 未来かどうか | true/false |
| `isThisWeek` | 今週かどうか | true/false |
| `isThisMonth` | 今月かどうか | true/false |
| `isThisYear` | 今年かどうか | true/false |
| `isDst` | サマータイム適用中かどうか | true/false |

### パターントークン

| トークン | 説明 | 例 |
|----------|------|-----|
| `yyyy` | 4桁の年 | 2025 |
| `MM`/`M` | 月（ゼロ埋め/なし） | 01, 1 |
| `MMM` | 月の略称 | Jan, Dec |
| `dd`/`d` | 日（ゼロ埋め/なし） | 01, 1 |
| `EEE` | 曜日の略称 | Mon, Sun |
| `HH`/`H` | 24時間制（ゼロ埋め/なし） | 09, 9 |
| `hh`/`h` | 12時間制（ゼロ埋め/なし） | 02, 2 |
| `mm`/`m` | 分（ゼロ埋め/なし） | 05, 5 |
| `ss`/`s` | 秒（ゼロ埋め/なし） | 05, 5 |
| `SSS` | ミリ秒 | 123 |
| `a` | 午前/午後 | AM, PM |
| `xxxxx` | タイムゾーンオフセット（コロン付き） | +08:00, -05:00 |
| `xxxx` | タイムゾーンオフセット | +0800, -0500 |
| `xx` | 短いタイムゾーンオフセット | +08, -05 |
| `X` | UTCはZ、それ以外はオフセット | Z, +0800 |

---

## 拡張機能の競合回避

本パッケージは `int` 型への拡張（`1.days` 等）を提供します。他パッケージと競合する場合は、`hide` キーワードで回避してください。

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

### 等価性の比較

`EasyDateTime` は Dart の `DateTime` と同じ等価性セマンティクスに従います：

```dart
final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
final local = EasyDateTime.parse('2025-01-01T08:00:00+08:00');

// 同じ瞬間、異なるタイムゾーンタイプ（UTC vs 非 UTC）
utc == local;                  // false
utc.isAtSameMomentAs(local);   // true
```

| メソッド | 比較対象 | 使用場面 |
|----------|----------|----------|
| `==` | 瞬間 + タイムゾーンタイプ（UTC/非 UTC） | 完全一致 |
| `isAtSameMomentAs()` | 絶対時間のみ | タイムゾーン間比較 |
| `isBefore()` / `isAfter()` | 時系列順序 | ソート、範囲チェック |

> [!WARNING]
> **`EasyDateTime` と `DateTime` を同じ `Set` や `Map` で混在させないでください**。
> `==` はクロスタイプで動作しますが、`hashCode` の実装が異なります。

### その他の注意点

* 有効な IANA タイムゾーンオフセットのみがサポートされます。非標準のオフセットはエラーとなります。
* 使用前に `EasyDateTime.initializeTimeZone()` の呼び出しが必要です。

### DateTime の挙動

EasyDateTime は Dart の `DateTime` から特定の挙動を継承しています：

**無効な日付のロールオーバー**：無効な日付を構築すると、次の有効な日付に自動的にロールオーバーします：
```dart
EasyDateTime(2025, 2, 30);  // → 2025-03-02 (2月30日は存在しない)
EasyDateTime(2025, 2, 29);  // → 2025-03-01 (2025年はうるう年ではない)
```

> DST 対応の日付演算については、[カレンダー日演算](#カレンダー日演算サマータイム対応)を参照してください。

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
