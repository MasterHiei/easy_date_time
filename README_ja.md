# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md) | [中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md)

IANA タイムゾーン対応の `DateTime` 代替ライブラリ。解析時に元のタイムゾーン情報を保持し、`DateTime` インターフェースを完全実装しているため、既存コードからの移行もスムーズです。

~~~dart
// DateTime: UTC に自動変換され、時差情報が失われる
DateTime.parse('2025-12-07T10:30:00+08:00').hour // 2

// EasyDateTime: 元の値を維持
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour // 10
~~~

## 導入

### 依存関係

`pubspec.yaml` に追加：

~~~yaml
dependencies:
  easy_date_time: ^0.9.1
~~~

### 初期化

使用前にタイムゾーンデータベースの初期化が必要です：

~~~dart
void main() {
  // アプリ起動時に一度だけ呼び出す
  EasyDateTime.initializeTimeZone();
  runApp(MyApp());
}
~~~

## 使い方

インスタンス作成とタイムゾーン付き解析：

~~~dart
// 定義済み定数を使用
final now = EasyDateTime.now(location: TimeZones.tokyo);

// 文字列解析（タイムゾーン情報を保持）
final parsed = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(parsed.hour);         // 10
print(parsed.locationName); // Asia/Shanghai
~~~

`Duration` 拡張を使った直感的な演算：

~~~dart
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
~~~

パターン文字列でのフォーマット：

~~~dart
const pattern = 'yyyy-MM-dd HH:mm';
print(dt.format(pattern)); // 2025-12-07 10:30
~~~

## 機能

### タイムゾーン

3つの指定方法：

~~~dart
// 1. TimeZones 定数
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);

// 2. IANA タイムゾーン名
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));

// 3. グローバル デフォルト
EasyDateTime.setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // Asia/Shanghai
~~~

タイムゾーン変換：

~~~dart
final newYork = tokyo.inLocation(TimeZones.newYork);
// 同一時刻か判定（時差は考慮される）
print(tokyo.isAtSameMomentAs(newYork)); // true
~~~

### 日付演算

`Duration` 拡張で可読性向上：

~~~dart
now + 1.days
now - 2.hours
now + 30.minutes + 15.seconds
~~~

**サマータイム (DST) を考慮した演算**：
DST 切り替え日を跨ぐ加減算では、`addCalendarDays` を使うことで「Wall Time（実時間）」を維持できます。

~~~dart
// ニューヨークの DST 開始日（2025年3月9日は23時間しかない）
final dt = EasyDateTime(2025, 3, 9, 0, 0, location: newYork);

dt.addCalendarDays(1);     // 2025-03-10 00:00 (時刻を保持)
dt.add(Duration(days: 1)); // 2025-03-10 01:00 (物理的に +24h)
~~~

便利なゲッター：

~~~dart
dt.tomorrow    // 翌日
dt.yesterday   // 前日
dt.dateOnly    // 日付部分のみ (00:00:00)
~~~

**月のオーバーフロー処理**：
月の変更で日付が無効になる場合（例：1月31日 → 2月）の挙動：

~~~dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // 3月3日 (自動繰り越し)
jan31.copyWithClamped(month: 2); // 2月28日 (月末日でクリップ)
~~~

**時間単位の境界**：

~~~dart
dt.startOf(DateTimeUnit.day);   // 当日の 00:00:00
dt.startOf(DateTimeUnit.week);  // 今週の月曜 00:00:00 (ISO 8601)
dt.startOf(DateTimeUnit.month); // 当月1日の 00:00:00
dt.endOf(DateTimeUnit.month);   // 当月末日の 23:59:59.999999
~~~

### プロパティ

計算プロパティ：

- `dayOfYear` — 通算日 (1-366)
- `weekOfYear` — ISO 8601 週番号 (1-53)
- `quarter` — 四半期 (1-4)
- `daysInMonth` — 月の日数 (28-31)
- `isLeapYear` — うるう年

状態判定：

- `isToday`、`isTomorrow`、`isYesterday`
- `isThisWeek`、`isThisMonth`、`isThisYear`
- `isWeekend` (土日)、`isWeekday` (月〜金)
- `isPast`、`isFuture`
- `isDst` — DST (夏時間) 期間中か

### フォーマット

`format()` とパターン文字：

~~~dart
dt.format('yyyy-MM-dd');    // 2025-12-07
dt.format('HH:mm:ss');      // 14:30:45
dt.format('hh:mm a');       // 02:30 PM (12時間制)
~~~

定義済み定数：

~~~dart
dt.format(DateTimeFormats.isoDate);      // 2025-12-07
dt.format(DateTimeFormats.isoDateTime);  // 2025-12-07T14:30:45
dt.format(DateTimeFormats.rfc2822);      // Mon, 07 Dec 2025 14:30:45 +0800
~~~

> **パフォーマンス**: ループ内などは `EasyDateTimeFormatter` の再利用を推奨。

~~~dart
static final formatter = EasyDateTimeFormatter('yyyy-MM-dd HH:mm');
String result = formatter.format(dt);
~~~

| トークン | 説明 | 例 |
|----------|------|----|
| `yyyy` | 4桁年 | 2025 |
| `MM` / `M` | 月 | 01 / 1 |
| `dd` / `d` | 日 | 07 / 7 |
| `HH` / `H` | 24時間 | 09 / 9 |
| `hh` / `h` | 12時間 | 02 / 2 |
| `mm` / `m` | 分 | 05 / 5 |
| `ss` / `s` | 秒 | 05 / 5 |
| `SSS` | ミリ秒 | 123 |
| `a` | AM / PM | AM / PM |
| `EEE` | 曜日 | Mon |
| `MMM` | 月名 | Dec |
| `xxxxx` | オフセット | +08:00 |
| `X` | ISOオフセット | Z / +0800 |

### 国際化 (intl)

`EasyDateTime` は `DateTime` インターフェースを実装しており、`intl` パッケージと直接連携可能：

~~~dart
import 'package:intl/intl.dart';

// 2025年12月7日
DateFormat.yMMMMd('ja_JP').format(dt);
// December 7, 2025
DateFormat.yMMMMd('en_US').format(dt);
~~~

### JSON シリアライズ

`json_serializable` や `freezed` 用のカスタム `JsonConverter`：

~~~dart
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromIso8601String(json);

  @override
  String toJson(EasyDateTime object) => object.toIso8601String();
}
~~~

`freezed` での使用例：

~~~dart
@freezed
class Event with _$Event {
  const factory Event({
    @EasyDateTimeConverter() required EasyDateTime startTime,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
~~~

## 注意事項

**等価性 (`==`)**：
Dart の `DateTime` 仕様に準拠。

~~~dart
final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
final local = EasyDateTime.parse('2025-01-01T08:00:00+08:00'); // UTC+8

// false — タイムゾーン種別が異なる (UTC vs Local)
print(utc == local);

// true — 同一時刻（時差は異なる）
print(utc.isAtSameMomentAs(local));
~~~

> **重要**：`EasyDateTime` と `DateTime` は `hashCode` 実装が異なるため、同じ `Set` に入れたり、`Map` のキーとして混在させないでください。

**日付の自動補正**：
無効な日付は自動的に繰り越されます。

~~~dart
// 2月30日は存在しないため、3月2日になる
EasyDateTime(2025, 2, 30); // -> 2025-03-02
~~~

**ユーザー入力の解析**：
安全性向上のため、入力値には `tryParse` の使用を推奨します。

~~~dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  // フォーマットエラー
}
~~~

**拡張メソッドの競合**：
`1.days` 等が他ライブラリ（`time` 等）と競合する場合、該当する拡張を `hide` してください：

~~~dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
~~~

## 貢献

Issue や PR は大歓迎です。詳細は [CONTRIBUTING.md](CONTRIBUTING.md) をご覧ください。

## ライセンス

BSD 2-Clause
