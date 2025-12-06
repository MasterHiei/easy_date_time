# easy_date_time

**タイムゾーン対応の Dart DateTime ライブラリ**

`timezone` パッケージを基盤とした、シンプルなタイムゾーン処理ライブラリです。

[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)

**[English](README.md)** | **[中文](README_zh.md)**

---

## 特徴

- 🌍 **任意の IANA タイムゾーンに対応**: `Asia/Tokyo` や `America/New_York` など、UTC 以外の時差も正確に扱えます。
- 🕒 **見たままの時刻を維持**: `"10:00+09:00"` を解析すると、（UTC 変換せず）そのまま **10:00** として扱います。
- 🛠️ **使いやすい設計**: 直感的な演算子（`now + 1.days`）と標準的な JSON シリアライズを提供。

## クイックスタート

```yaml
dependencies:
  easy_date_time: ^0.1.0
```

```dart
import 'package:easy_date_time/easy_date_time.dart';

void main() {
  // 1. 初期化 (基盤)
  initializeTimeZone();

  // 2. デフォルト設定 (任意)
  // 設定しない場合は、システムのローカル設定が使用されます
  setDefaultLocation(TimeZones.tokyo);

  final now = EasyDateTime.now();  // デフォルト設定を使用 (東京時間)
  print(now);
}
```

---

## タイムゾーンの指定

### 方法 1: `TimeZones` ショートカットを使用（推奨）

```dart
// よく使うタイムゾーンはプロパティとして利用可能
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
final newYork = EasyDateTime.now(location: TimeZones.newYork);

// 利用可能: tokyo, shanghai, beijing, hongKong, singapore,
// newYork, losAngeles, chicago, london, paris, berlin,
// sydney, auckland, moscow, dubai, mumbai など...
```

### 方法 2: `getLocation()` で任意の IANA タイムゾーンを取得

```dart
// TimeZones にないタイムゾーン
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
final denver = EasyDateTime.now(location: getLocation('America/Denver'));

// 完全なリスト: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
```

### 方法 3: グローバルデフォルトを設定

```dart
// 一度設定すれば、以降の操作に自動適用
setDefaultLocation(TimeZones.tokyo);

final now = EasyDateTime.now();  // 東京時間
final dt = EasyDateTime(2025, 12, 25, 10, 30);  // これも東京時間
```

---

## 日時文字列の解析

**元の時刻値を保持** — 自動変換しません:

```dart
// タイムゾーンオフセット付きの API レスポンスを解析
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
print(dt.hour);  // 10（2 ではない！）
print(dt.locationName);  // Asia/Shanghai

// UTC 時刻を解析
final utc = EasyDateTime.parse('2025-12-07T10:30:00Z');
print(utc.hour);  // 10
print(utc.locationName);  // UTC

// 明示的な変換（リクエストした場合のみ）
final inNY = EasyDateTime.parse(
  '2025-12-07T10:30:00Z',
  location: TimeZones.newYork,
);
print(inNY.hour);  // 5（10 UTC → 5 ニューヨーク）
```

---

## タイムゾーン変換

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);

// 別のタイムゾーンに変換
final newYork = tokyo.inLocation(TimeZones.newYork);

// UTC に変換
final utc = tokyo.inUtc();

// 同じ瞬間、異なる表示
print(tokyo.isAtSameMoment(newYork));  // true
```

---

## 日付演算

```dart
final now = EasyDateTime.now();

// 演算子で加減算
final tomorrow = now + 1.days;
final lastWeek = now - 1.weeks;
final later = now + 2.hours + 30.minutes;

// 比較
if (tomorrow > now) {
  print('未来');
}

// 差分を計算
final duration = tomorrow.difference(now);
```

---

## JSON シリアライゼーション

json_serializable と freezed に対応しています:

```dart
// 手動変換
final json = dt.toJson();  // "2025-12-25T10:30:00.000+0900"
final restored = EasyDateTime.fromJson(json);

// freezed/json_serializable と組み合わせ - カスタムコンバーターを定義:
class EasyDateTimeConverter implements JsonConverter<EasyDateTime, String> {
  const EasyDateTimeConverter();

  @override
  EasyDateTime fromJson(String json) => EasyDateTime.fromJson(json);

  @override
  String toJson(EasyDateTime object) => object.toJson();
}

// モデルで使用:
@freezed
class Event with _$Event {
  const factory Event({
    @EasyDateTimeConverter() required EasyDateTime startTime,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
```

完全な例は [example/lib/integrations/](example/lib/integrations/) をご覧ください。



## API リファレンス

### コンストラクタ

| コンストラクタ | 説明 |
|--------------|------|
| `EasyDateTime(year, month, day, ...)` | 各要素から作成 |
| `EasyDateTime.now()` | 現在時刻 |
| `EasyDateTime.utc(...)` | UTC で作成 |
| `EasyDateTime.parse(string)` | ISO 8601 を解析 |
| `EasyDateTime.fromJson(string)` | JSON から解析 |

### タイムゾーンメソッド

| メソッド | 説明 |
|---------|------|
| `inLocation(location)` | 指定タイムゾーンに変換 |
| `inUtc()` | UTC に変換 |
| `inLocalTime()` | システムローカルに変換 |

### 日付ユーティリティ

| プロパティ/メソッド | 説明 |
|-------------------|------|
| `isToday` | 今日かどうか |
| `isTomorrow` | 明日かどうか |
| `isYesterday` | 昨日かどうか |
| `startOfDay` | 当日 00:00:00 |
| `endOfDay` | 当日 23:59:59 |
| `startOfMonth` | 月初日 |
| `endOfMonth` | 月末日 |

---

## ライセンス

BSD 2-Clause License
