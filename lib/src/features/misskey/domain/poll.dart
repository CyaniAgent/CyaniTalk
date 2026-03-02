import 'package:freezed_annotation/freezed_annotation.dart';

part 'poll.freezed.dart';
part 'poll.g.dart';

/// 投票模式枚举
enum PollMode {
  /// 永久投票（无截止时间）
  permanent,

  /// 指定截止日期
  date,

  /// 相对时间
  relative,
}

/// 相对时间单位
enum PollTimeUnit {
  /// 秒
  seconds,

  /// 分钟
  minutes,

  /// 小时
  hours,

  /// 天
  days,
}

/// 投票选项
@freezed
abstract class PollChoice with _$PollChoice {
  const factory PollChoice({required String text}) = _PollChoice;

  factory PollChoice.fromJson(Map<String, dynamic> json) =>
      _$PollChoiceFromJson(json);
}

/// 投票配置
@freezed
abstract class Poll with _$Poll {
  const factory Poll({
    /// 投票选项列表（2-10 个）
    required List<String> choices,

    /// 是否允许多选
    @Default(false) bool multiple,

    /// 投票模式
    @Default(PollMode.permanent) PollMode mode,

    /// 截止日期（mode 为 date 时使用）
    DateTime? expiresAt,

    /// 相对时间值（mode 为 relative 时使用）
    int? relativeValue,

    /// 相对时间单位（mode 为 relative 时使用）
    PollTimeUnit? relativeUnit,
  }) = _Poll;

  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);
}

/// 投票结果（从 API 返回）
@freezed
abstract class PollResult with _$PollResult {
  const factory PollResult({
    required List<PollChoiceResult> choices,
    @Default(false) bool multiple,
    DateTime? expiresAt,
    @Default(0) int votesCount,
  }) = _PollResult;

  factory PollResult.fromJson(Map<String, dynamic> json) =>
      _$PollResultFromJson(json);
}

/// 投票选项结果
@freezed
abstract class PollChoiceResult with _$PollChoiceResult {
  const factory PollChoiceResult({
    required String text,
    required int votes,
    @Default(false) bool isVoted,
  }) = _PollChoiceResult;

  factory PollChoiceResult.fromJson(Map<String, dynamic> json) =>
      _$PollChoiceResultFromJson(json);
}

/// 投票时间设置
@freezed
abstract class PollTimeSetting with _$PollTimeSetting {
  const factory PollTimeSetting({
    required PollMode mode,
    DateTime? expiresAt,
    int? relativeValue,
    PollTimeUnit? relativeUnit,
  }) = _PollTimeSetting;

  factory PollTimeSetting.fromJson(Map<String, dynamic> json) =>
      _$PollTimeSettingFromJson(json);
}

/// 将相对时间转换为毫秒
int convertRelativeTimeToMs(int value, PollTimeUnit unit) {
  return switch (unit) {
    PollTimeUnit.seconds => value * 1000,
    PollTimeUnit.minutes => value * 60 * 1000,
    PollTimeUnit.hours => value * 60 * 60 * 1000,
    PollTimeUnit.days => value * 24 * 60 * 60 * 1000,
  };
}

/// 将毫秒转换为相对时间设置
(PollTimeUnit, int) convertMsToRelativeTime(int ms) {
  if (ms < 60 * 1000) {
    return (PollTimeUnit.seconds, ms ~/ 1000);
  } else if (ms < 60 * 60 * 1000) {
    return (PollTimeUnit.minutes, ms ~/ (60 * 1000));
  } else if (ms < 24 * 60 * 60 * 1000) {
    return (PollTimeUnit.hours, ms ~/ (60 * 60 * 1000));
  } else {
    return (PollTimeUnit.days, ms ~/ (24 * 60 * 60 * 1000));
  }
}

/// 验证投票配置是否有效
bool isValidPoll(Poll poll) {
  // 选项数量必须在 2-10 之间
  if (poll.choices.length < 2 || poll.choices.length > 10) {
    return false;
  }

  // 所有选项不能为空
  if (poll.choices.any((choice) => choice.trim().isEmpty)) {
    return false;
  }

  // 选项不能重复
  final trimmedChoices = poll.choices.map((c) => c.trim()).toList();
  final uniqueChoices = trimmedChoices.toSet();
  if (uniqueChoices.length != trimmedChoices.length) {
    return false;
  }

  // 如果是 date 模式，必须有截止日期且不能是过去时间
  if (poll.mode == PollMode.date) {
    if (poll.expiresAt == null) {
      return false;
    }
    // 检查是否是过去时间
    if (poll.expiresAt!.isBefore(DateTime.now())) {
      return false;
    }
  }

  // 如果是 relative 模式，必须有相对时间设置
  if (poll.mode == PollMode.relative &&
      (poll.relativeValue == null || poll.relativeUnit == null)) {
    return false;
  }

  return true;
}

/// 获取投票的截止时间戳（毫秒）
int? getPollExpiresAtMs(Poll poll) {
  if (poll.mode == PollMode.permanent) {
    return null;
  } else if (poll.mode == PollMode.date) {
    return poll.expiresAt?.millisecondsSinceEpoch;
  } else if (poll.mode == PollMode.relative) {
    if (poll.relativeValue == null || poll.relativeUnit == null) {
      return null;
    }
    // relative 模式返回从当前时间开始的相对时间戳
    final now = DateTime.now();
    final expiresAt = now.add(
      Duration(
        milliseconds: convertRelativeTimeToMs(
          poll.relativeValue!,
          poll.relativeUnit!,
        ),
      ),
    );
    return expiresAt.millisecondsSinceEpoch;
  }
  return null;
}

/// 将投票配置转换为 API 请求参数
Map<String, dynamic> pollToApiParams(Poll poll) {
  final params = <String, dynamic>{
    'choices': poll.choices.map((c) => c.trim()).toList(),
    'multiple': poll.multiple,
  };

  final expiresAtMs = getPollExpiresAtMs(poll);
  if (expiresAtMs != null) {
    params['expiredAfter'] = expiresAtMs;
  }

  return params;
}
