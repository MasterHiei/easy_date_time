# easy_date_time

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![Pub Points](https://img.shields.io/pub/points/easy_date_time)](https://pub.dev/packages/easy_date_time/score)
[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)
[![License](https://img.shields.io/badge/license-BSD--2--Clause-blue.svg)](https://opensource.org/licenses/BSD-2-Clause)

[English](https://github.com/MasterHiei/easy_date_time/blob/main/README.md) | [中文](https://github.com/MasterHiei/easy_date_time/blob/main/README_zh.md)

IANA タイムゾーンをサポートする、`DateTime` の代替ライブラリです。
解析時に元の時間値とタイムゾーン情報を保持します。`DateTime` インターフェースを実装しているため、置き換えが容易です。

~~~dart
// DateTime: タイムゾーンをまたぐと UTC に自動変換され、時間が変わってしまう
DateTime.parse('2026-01-18T10:30:00+08:00').hour // 2

// EasyDateTime: 元の時間とタイムゾーン情報を保持
EasyDateTime.parse('2026-01-18T10:30:00+08:00').hour // 10
~~~

## 導入

### 依存関係

`pubspec.yaml` に以下を追加してください：

~~~yaml
dependencies:
  easy_date_time: ^0.11.0
~~~

### 初期化

**注意**：ライブラリを使用する前に、必ずタイムゾーンデータベースを初期化する必要があります。

~~~dart
void main() {
  // アプリ起動時（機能利用前）に一度だけ呼び出してください
  EasyDateTime.initializeTimeZone();
  runApp(MyApp());
}
~~~

## 使い方

インスタンスの作成とタイムゾーン付き解析：

~~~dart
// 定義済みのロケーション定数を使用
final now = EasyDateTime.now(location: TimeZones.tokyo);

// 文字列を解析（オフセットとロケーション情報を保持）
final parsed = EasyDateTime.parse('2026-01-18T10:30:00+08:00');

print(parsed.hour);         // 10
print(parsed.locationName); // Asia/Shanghai
~~~

`Duration` 拡張を使った演算：

~~~dart
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
~~~

パターン文字列でのフォーマット：

~~~dart
const pattern = 'yyyy-MM-dd HH:mm';
print(dt.format(pattern)); // 2026-01-18 10:30
~~~

## 機能

### タイムゾーン

タイムゾーン（Location）は3つの方法で指定可能です：

~~~dart
// 1. TimeZones 定数を使用（推奨）
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);

// 2. IANA タイムゾーン名を使用
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));

// 3. グローバルデフォルトを設定
EasyDateTime.setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // デフォルトで Asia/Shanghai になります
~~~

タイムゾーン間の変換：

~~~dart
final newYork = tokyo.inLocation(TimeZones.newYork);
// 物理的に同一時刻かを判定（時差は考慮されます）
print(tokyo.isAtSameMomentAs(newYork)); // true
~~~

### 日付演算

`Duration` 拡張により、簡潔に記述できます：

~~~dart
now + 1.days
now - 2.hours
now + 30.minutes + 15.seconds
~~~

**サマータイム (DST) を考慮した演算**

DST の切り替え日をまたぐ加減算において、`addCalendarDays` は「壁時計の時刻（Wall Time）」を維持し、通常の加算は物理的な時間を基準にします。

~~~dart
// ニューヨークの DST 開始日（2025年3月9日：時計が1時間進む日）
final dt = EasyDateTime(2025, 3, 9, 0, 0, location: newYork);

dt.addCalendarDays(1);     // 2025-03-10 00:00 (時計の時刻を保持)
dt.add(Duration(days: 1)); // 2025-03-10 01:00 (物理的に +24時間)
~~~

便利なプロパティ：

~~~dart
dt.tomorrow    // 翌暦日
dt.yesterday   // 前暦日
dt.dateOnly    // 時間部分を切り捨て (00:00:00)
~~~

**月のオーバーフロー処理**

月の変更によって日付が無効になる場合（例：1月31日 → 2月）、2通りの挙動を選択できます：

~~~dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // 3月3日 (標準的な自動繰り越し)
jan31.copyWithClamped(month: 2); // 2月28日 (その月の月末日でクリップ)
~~~

**時間単位の境界算出**

指定単位の開始・終了時刻を簡単に取得できます：

~~~dart
dt.startOf(DateTimeUnit.day);   // 当日の 00:00:00
dt.startOf(DateTimeUnit.week);  // 今週の月曜 00:00:00 (ISO 8601準拠)
dt.startOf(DateTimeUnit.month); // 当月1日の 00:00:00
dt.endOf(DateTimeUnit.month);   // 当月末日の 23:59:59.999
~~~

### プロパティ

日付コンポーネント：

- `dayOfYear` — 通算日 (1-366)
- `weekOfYear` — ISO 8601 週番号 (1-53)
- `quarter` — 四半期 (1-4)
- `daysInMonth` — その月の日数 (28-31)
- `isLeapYear` — うるう年なら true

状態判定：

- `isToday`, `isTomorrow`, `isYesterday`
- `isThisWeek`, `isThisMonth`, `isThisYear`
- `isWeekend` (土日), `isWeekday` (月〜金)
- `isPast` (過去), `isFuture` (未来)
- `isDst` — 現在、夏時間 (DST) 適用中か

### フォーマット

`format()` とパターン記号で整形します：

~~~dart
dt.format('yyyy-MM-dd');    // 2026-01-18
dt.format('HH:mm:ss');      // 14:30:45
dt.format('hh:mm a');       // 02:30 PM (12時間制)
~~~

定義済み定数も利用可能です：

~~~dart
dt.format(DateTimeFormats.isoDate);      // 2026-01-18
dt.format(DateTimeFormats.isoDateTime);  // 2026-01-18T14:30:45
dt.format(DateTimeFormats.rfc2822);      // Sun, 18 Jan 2026 14:30:45 +0800
~~~

> **パフォーマンス**: ループ処理などでは、`EasyDateTimeFormatter` インスタンスを定数として再利用することを推奨します。

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

`EasyDateTime` は `DateTime` インターフェースを実装しているため、`package:intl` と直接連携できます：

~~~dart
import 'package:intl/intl.dart';

// 2025年12月7日
DateFormat.yMMMMd('ja_JP').format(dt);
// December 7, 2025
DateFormat.yMMMMd('en_US').format(dt);
~~~

### JSON シリアライズ

`json_serializable` や `freezed` 用のカスタム `JsonConverter` を提供しています：

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

**等価性 (`==`) の仕様**
Dart の `DateTime` セマンティクスに準拠しています。
- `==` は、絶対時間 (Instant) **かつ** タイムゾーン (Location) が一致する場合に真となります。
- `isAtSameMomentAs` は、絶対時間のみを比較します。

~~~dart
final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
final local = EasyDateTime.parse('2026-01-18T08:00:00+08:00'); // UTC+8

// false — タイムゾーン種別が異なるため (UTC vs Local)
print(utc == local);

// true — 同一時刻であるため（時差は関係なし）
print(utc.isAtSameMomentAs(local));
~~~

> **重要**：`EasyDateTime` と `DateTime` は `hashCode` の実装が異なるため、同じ `Set` に入れたり、`Map` のキーとして混在させないでください。

**自動補正と厳密モード (Strict Mode)**

`strict` パラメータは `parse()` と `tryParse()` メソッド**のみ**で利用可能で、コンストラクタでは使用できません。

**コンストラクタの挙動**（常に繰り越し）：

~~~dart
// コンストラクタは常に繰り越される - 厳密モード非対応
EasyDateTime(2025, 2, 30);     // 2025-03-02 になる
EasyDateTime.utc(2025, 4, 31); // 2025-05-01 になる
~~~

**解析メソッド**は `strict` パラメータで厳密な検証をサポート：

~~~dart
// デフォルト：無効な日付は繰り越される
EasyDateTime.parse('2025-02-30');  // 2025-03-02

// 厳密モード：無効な日付で FormatException をスロー
EasyDateTime.parse('2025-02-30', strict: true);  // ❌ FormatException

// 厳密モード + tryParse：無効な日付で null を返す
EasyDateTime.tryParse('2025-02-30', strict: true);  // null
~~~

> **注意**: 厳密モードはカレンダーの正確性（2月30日や13月の拒否など）と ISO 8601 形式への準拠を検証します。ユーザー入力の安全な検証には `tryParse()` と `strict: true` の組み合わせを推奨します。



**ユーザー入力の安全な解析**
ユーザー入力を扱う際は、`tryParse` を使用して実行時エラーを防ぐことを強く推奨します：

~~~dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  // フォーマットエラー処理
}
~~~

**拡張メソッドの競合回避**
`1.days` などの便利な拡張機能が、他のライブラリ（`time` パッケージなど）と競合する場合は、該当する拡張を `hide` してください：

~~~dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
~~~

## 貢献

バグ報告やプルリクエストは大歓迎です。詳細は [CONTRIBUTING.md](CONTRIBUTING.md) をご覧ください。

## ライセンス

BSD 2-Clause
