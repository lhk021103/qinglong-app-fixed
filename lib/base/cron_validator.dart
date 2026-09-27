/// 定时规则校验，对齐青龙后端 back/validation/schedule.ts 的 validateSchedule：
///  1. 以 @once / @boot 开头 -> 直接通过
///  2. 出现裸 /N（" /5" 或 "/5"）-> 无效（cron-parser 会放过，但 node-schedule 注册失败）
///  3. 出现 ? （Quartz 语法）-> 无效
///  4. 其余交给 Cron 解析器，能算出下一次触发时间才算通过
///
/// 原 app 只在提交前做了「非空」校验，类似 "* * *" 这种 3 段式会被原样提交，
/// 面板返回「无效的定时规则」，任务入库失败却提示成功。
library cron_validator;

import 'package:qinglong_app/base/cron_parse.dart';

class CronValidator {
  CronValidator._();

  static const String once = "@once";
  static const String boot = "@boot";

  /// 返回 null 表示合法，否则返回可直接提示给用户的错误文案
  static String? validate(String? schedule) {
    final value = (schedule ?? "").trim();
    if (value.isEmpty) {
      return "定时规则不能为空";
    }

    if (value.startsWith(once) || value.startsWith(boot)) {
      return null;
    }

    if (RegExp(r'\s/\d').hasMatch(value) || RegExp(r'^/\d').hasMatch(value)) {
      return "无效的定时规则：不支持裸 /N 写法，请写成 */N";
    }

    if (value.contains("?")) {
      return "无效的定时规则：不支持 Quartz 的 ? 语法";
    }

    final fields = value.split(RegExp(r'\s+'));
    if (fields.length < 5 || fields.length > 6) {
      return "定时规则需要 5 位（分 时 日 月 周）或 6 位（秒 分 时 日 月 周）";
    }

    try {
      Cron().parse(value, "UTC").next();
    } catch (e) {
      return "无效的定时规则";
    }
    return null;
  }
}
