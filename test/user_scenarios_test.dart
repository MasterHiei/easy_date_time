/// 用户场景模拟测试
/// 模拟真实用户的使用流程，确保核心场景被测试覆盖
library;

import 'package:easy_date_time/easy_date_time.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    initializeTimeZone();
  });

  tearDown(() {
    clearDefaultLocation();
  });

  group('场景1: Flutter 应用启动', () {
    test('初始化后获取当前时间', () {
      // 用户: 在 main() 中调用 initializeTimeZone() 后获取当前时间
      final now = EasyDateTime.now();

      expect(now, isNotNull);
      expect(now.year, greaterThanOrEqualTo(2024));
    });

    test('设置全局默认时区', () {
      // 用户: 设置应用默认时区为上海
      setDefaultLocation(TimeZones.shanghai);
      final now = EasyDateTime.now();

      expect(now.locationName, 'Asia/Shanghai');
    });
  });

  group('场景2: API 响应处理', () {
    test('解析后端返回的 ISO 8601 时间 (带时区)', () {
      // 后端返回: "2025-12-07T10:30:00+08:00"
      // 用户期望: hour=10, 不被转换
      const apiResponse = '2025-12-07T10:30:00+08:00';
      final dt = EasyDateTime.parse(apiResponse);

      expect(dt.hour, 10);
      expect(dt.minute, 30);
    });

    test('解析后端返回的 UTC 时间', () {
      // 后端返回: "2025-12-07T02:30:00Z"
      const apiResponse = '2025-12-07T02:30:00Z';
      final dt = EasyDateTime.parse(apiResponse);

      expect(dt.hour, 2);
      expect(dt.locationName, 'UTC');
    });

    test('解析失败时返回 null (tryParse)', () {
      // 用户: 处理可能无效的输入
      const invalidInput = 'not-a-date';
      final dt = EasyDateTime.tryParse(invalidInput);

      expect(dt, isNull);
    });

    test('JSON 序列化往返', () {
      // 用户: 与 json_serializable 配合使用
      final original = EasyDateTime.parse('2025-12-07T10:30:00+08:00');
      final json = original.toJson();
      final restored = EasyDateTime.fromJson(json);

      expect(restored.isAtSameMoment(original), isTrue);
    });
  });

  group('场景3: 电商应用-活动时间处理', () {
    test('判断活动是否开始', () {
      // 用户: 判断当前时间是否在活动开始之后
      final activityStart = EasyDateTime(2020, 1, 1, 0, 0);
      final now = EasyDateTime.now();

      expect(now.isAfter(activityStart), isTrue);
    });

    test('计算活动剩余时间', () {
      // 用户: 计算距离活动结束还有多久
      final activityEnd = EasyDateTime(2099, 12, 31, 23, 59, 59);
      final now = EasyDateTime.now();
      final remaining = activityEnd.difference(now);

      expect(remaining.inDays, greaterThan(0));
    });

    test('判断今日是否是活动日', () {
      // 用户: 判断某个日期是否是今天
      final now = EasyDateTime.now();

      expect(now.isToday, isTrue);
      expect(now.isTomorrow, isFalse);
      expect(now.isYesterday, isFalse);
    });
  });

  group('场景4: 日历应用-日期操作', () {
    test('获取某日的开始和结束时间', () {
      final dt = EasyDateTime(2025, 12, 7, 15, 30);

      final startOfDay = dt.startOfDay;
      final endOfDay = dt.endOfDay;

      expect(startOfDay.hour, 0);
      expect(startOfDay.minute, 0);
      expect(endOfDay.hour, 23);
      expect(endOfDay.minute, 59);
      expect(endOfDay.second, 59);
    });

    test('获取月初和月末', () {
      final dt = EasyDateTime(2025, 2, 15);

      final startOfMonth = dt.startOfMonth;
      final endOfMonth = dt.endOfMonth;

      expect(startOfMonth.day, 1);
      expect(endOfMonth.day, 28); // 2025年2月非闰年
    });

    test('跳转到明天/昨天', () {
      final today = EasyDateTime(2025, 12, 7, 10, 30);

      final tomorrow = today.tomorrow;
      final yesterday = today.yesterday;

      expect(tomorrow.day, 8);
      expect(yesterday.day, 6);
    });

    test('使用 Duration 添加时间', () {
      final dt = EasyDateTime(2025, 12, 7, 10, 0);
      final later = dt + const Duration(hours: 2, minutes: 30);

      expect(later.hour, 12);
      expect(later.minute, 30);
    });
  });

  group('场景5: 国际化应用-时区转换', () {
    test('将本地时间转换为其他时区', () {
      // 用户: 在上海，想知道纽约的对应时间
      final shanghai = EasyDateTime(
        2025,
        12,
        7,
        20,
        0,
        0,
        0,
        0,
        TimeZones.shanghai,
      );
      final newYork = shanghai.inLocation(TimeZones.newYork);

      // 上海 20:00 = UTC 12:00 = 纽约 07:00 (冬令时 EST)
      expect(newYork.hour, 7);
      expect(shanghai.isAtSameMoment(newYork), isTrue);
    });

    test('转换为 UTC', () {
      final tokyo = EasyDateTime(
        2025,
        12,
        7,
        21,
        0,
        0,
        0,
        0,
        TimeZones.tokyo,
      );
      final utc = tokyo.inUtc();

      expect(utc.hour, 12); // Tokyo 21:00 = UTC 12:00
      expect(utc.locationName, 'UTC');
    });
  });

  group('场景6: 数据存储和比较', () {
    test('获取时间戳用于数据库存储', () {
      final dt = EasyDateTime.utc(2025, 1, 1, 0, 0);
      final timestamp = dt.millisecondsSinceEpoch;

      // 可以存储到数据库
      expect(timestamp, isPositive);

      // 可以还原
      final restored = EasyDateTime.fromMillisecondsSinceEpoch(timestamp);
      expect(restored.isAtSameMoment(dt), isTrue);
    });

    test('比较两个时间', () {
      final earlier = EasyDateTime(2025, 12, 7, 10, 0);
      final later = EasyDateTime(2025, 12, 7, 11, 0);

      expect(earlier < later, isTrue);
      expect(later > earlier, isTrue);
      expect(earlier <= later, isTrue);
      expect(later >= earlier, isTrue);
    });

    test('判断两个时间是否相等', () {
      final dt1 = EasyDateTime.utc(2025, 12, 7, 10, 30);
      final dt2 = EasyDateTime.utc(2025, 12, 7, 10, 30);

      expect(dt1 == dt2, isTrue);
    });
  });

  group('场景7: 与标准 DateTime 互操作', () {
    test('从 DateTime 转换', () {
      final stdDt = DateTime(2025, 12, 7, 10, 30);
      final easyDt = stdDt.toEasyDateTime();

      expect(easyDt.year, 2025);
      expect(easyDt.month, 12);
      expect(easyDt.day, 7);
    });

    test('转换回 DateTime', () {
      final easyDt = EasyDateTime(2025, 12, 7, 10, 30);
      final stdDt = easyDt.toDateTime();

      expect(stdDt, isA<DateTime>());
      expect(stdDt.year, 2025);
    });
  });

  group('场景8: copyWith 修改部分字段', () {
    test('修改时间保持日期', () {
      final dt = EasyDateTime(2025, 12, 7, 10, 30);
      final newDt = dt.copyWith(hour: 15, minute: 45);

      expect(newDt.day, 7); // 日期不变
      expect(newDt.hour, 15); // 时间变了
      expect(newDt.minute, 45);
    });

    test('修改日期保持时间', () {
      final dt = EasyDateTime(2025, 12, 7, 10, 30);
      final newDt = dt.copyWith(month: 6, day: 15);

      expect(newDt.month, 6);
      expect(newDt.day, 15);
      expect(newDt.hour, 10); // 时间不变
    });
  });

  group('场景9: 格式化输出', () {
    test('获取日期字符串', () {
      final dt = EasyDateTime(2025, 12, 7, 10, 30);
      final dateStr = dt.toDateString();

      expect(dateStr, '2025-12-07');
    });

    test('获取时间字符串', () {
      final dt = EasyDateTime(2025, 12, 7, 10, 30, 45);
      final timeStr = dt.toTimeString();

      expect(timeStr, '10:30:45');
    });

    test('获取 ISO 8601 字符串', () {
      final dt = EasyDateTime.utc(2025, 12, 7, 10, 30);
      final isoStr = dt.toIso8601String();

      expect(isoStr, contains('2025-12-07'));
      expect(isoStr, contains('10:30'));
    });
  });

  group('场景10: 错误处理', () {
    test('无效日期格式抛出异常', () {
      expect(
        () => EasyDateTime.parse('invalid-date'),
        throwsA(isA<InvalidDateFormatException>()),
      );
    });

    test('无效时区抛出异常', () {
      expect(
        () => getLocation('Invalid/Zone'),
        throwsA(anything), // getLocation throws LocationNotFoundException
      );
    });
  });
}
