# easy_date_time

**Dart でタイムゾーン付きの時間管理をもっと簡単に**

Dart 標準の `DateTime` では UTC とローカルしか扱えず、タイムゾーン付きの文字列を扱うと勝手に UTC に変換されてしまうことがあります。
`EasyDateTime` を使えば、入力した時間をそのまま保持しつつ、任意のタイムゾーンでの表示や計算が簡単に行えます。

[![Build Status](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml/badge.svg)](https://github.com/MasterHiei/easy_date_time/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/easy_date_time.svg)](https://pub.dev/packages/easy_date_time)
[![codecov](https://codecov.io/gh/MasterHiei/easy_date_time/branch/main/graph/badge.svg)](https://codecov.io/gh/MasterHiei/easy_date_time)

---

## 使う理由

Dart 標準の DateTime や他のライブラリは、実務で少し不便な点があります。

| ライブラリ                | メリット             | 制約                                       | easy_date_time の強み          |
| ----------------------- | ---------------- | ---------------------------------------- | ------------------------------ |
| DateTime（標準）          | シンプル、依存なし     | UTC とローカルのみ、タイムゾーン付き文字列を解析すると UTC に変換される | 入力した時間を保持、任意のタイムゾーンで扱える |
| timezone                | 正確な IANA タイムゾーン | API が複雑                                    | よく使うタイムゾーンは簡単に利用可能、API がシンプル |
| intl                    | フォーマットや国際化機能が充実 | タイムゾーン管理は限定的                             | 時間とタイムゾーンを分けて管理でき、操作が分かりやすい |
| flutter_native_timezone | デバイスのタイムゾーン取得が簡単 | 時間計算や解析は不可                               | 解析・加減算・タイムゾーン変換がすべて対応      |

> 簡単に言うと：**EasyDateTime を使えば Dart の時間処理がシンプルになり、タイムゾーンを跨いだアプリでも安心して使えます。**

**標準の DateTime との違い：**

```dart
// DateTime：オフセットは解析されるが、時間は UTC に変換される
DateTime.parse('2025-12-07T10:30:00+08:00').hour      // → 2 😕

// EasyDateTime：入力した時間がそのまま
EasyDateTime.parse('2025-12-07T10:30:00+08:00').hour  // → 10 ✓
```

---

## 特徴

* 🌍 **任意のタイムゾーンに対応**
  IANA タイムゾーン全般をサポート（例: Asia/Shanghai, America/New_York）

* 🕒 **入力した時間をそのまま保持**
  勝手に UTC に変換されることはありません

* ➕ **直感的な時間加減算**
  `now + 1.days`、`2.hours` など自然な書き方で操作可能

* 🔄 **明示的なタイムゾーン変換**
  `.inLocation()` または `.toUtc()` を呼ぶ時だけ変換されます

* 🧱 **安全に日付を変更**
  `copyWithClamped()` で月や日を超えないよう調整可能

---

## インストールと初期化

`pubspec.yaml` に追加：

```yaml
dependencies:
  easy_date_time: ^0.2.0
```

アプリ起動時に一度だけ初期化：

```dart
void main() {
  initializeTimeZone();  // 必ず呼ぶ

  // 任意：デフォルトタイムゾーンを設定
  setDefaultLocation(TimeZones.shanghai);

  runApp(MyApp());
}
```

---

## クイックスタート

```dart
final now = EasyDateTime.now();  // 設定したタイムゾーン、またはローカルタイムゾーン
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final parsed = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(parsed.hour);  // 10
```

---

## タイムゾーンの使い方

### よく使うタイムゾーン（推奨）

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
```

### 任意の IANA タイムゾーン

```dart
final nairobi = EasyDateTime.now(location: getLocation('Africa/Nairobi'));
```

### グローバルデフォルト

```dart
setDefaultLocation(TimeZones.shanghai);
final now = EasyDateTime.now(); // 上海時間をデフォルトで使用
```

---

## 入力時間を保持

```dart
final dt = EasyDateTime.parse('2025-12-07T10:30:00+08:00');

print(dt.hour);          // 10
print(dt.locationName);  // Asia/Shanghai
```

変換する場合：

```dart
final ny = dt.inLocation(TimeZones.newYork);
final utc = dt.toUtc();
```

---

## タイムゾーン変換例

```dart
final tokyo = EasyDateTime.now(location: TimeZones.tokyo);
final newYork = tokyo.inLocation(TimeZones.newYork);

print(tokyo.isAtSameMomentAs(newYork)); // true：同じ瞬間
```

---

## 日付計算

```dart
final now = EasyDateTime.now();
final tomorrow = now + 1.days;
final later = now + 2.hours + 30.minutes;
```

### 月をまたぐ場合の安全処理

```dart
final jan31 = EasyDateTime.utc(2025, 1, 31);

jan31.copyWith(month: 2);        // 3月3日（オーバーフロー）
jan31.copyWithClamped(month: 2); // 2月28日
```

```

---

## 拡張機能の競合について

このパッケージには、開発体験向上のために便利な `int` の拡張機能（`1.days` など）が含まれています。他のパッケージと競合する場合は、以下のように隠すことができます：

```dart
import 'package:easy_date_time/easy_date_time.dart' hide DurationExtension;
```

---

## JSON / シリアライズ対応

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

## 注意点

* `==` は「同じ瞬間」を比較
* IANA に登録されていないタイムゾーンはエラー
* `initializeTimeZone()` は必ず最初に呼ぶ

### 安全なユーザー入力解析

```dart
final dt = EasyDateTime.tryParse(userInput);
if (dt == null) {
  print('日付の形式が正しくありません');
}
```

---

## 貢献

Issue や PR を歓迎
`CONTRIBUTING.md` を参照してください

---

## License

BSD 2-Clause
