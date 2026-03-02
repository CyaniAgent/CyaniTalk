// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PollChoice _$PollChoiceFromJson(Map<String, dynamic> json) =>
    _PollChoice(text: json['text'] as String);

Map<String, dynamic> _$PollChoiceToJson(_PollChoice instance) =>
    <String, dynamic>{'text': instance.text};

_Poll _$PollFromJson(Map<String, dynamic> json) => _Poll(
  choices: (json['choices'] as List<dynamic>).map((e) => e as String).toList(),
  multiple: json['multiple'] as bool? ?? false,
  mode:
      $enumDecodeNullable(_$PollModeEnumMap, json['mode']) ??
      PollMode.permanent,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  relativeValue: (json['relativeValue'] as num?)?.toInt(),
  relativeUnit: $enumDecodeNullable(
    _$PollTimeUnitEnumMap,
    json['relativeUnit'],
  ),
);

Map<String, dynamic> _$PollToJson(_Poll instance) => <String, dynamic>{
  'choices': instance.choices,
  'multiple': instance.multiple,
  'mode': _$PollModeEnumMap[instance.mode]!,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'relativeValue': instance.relativeValue,
  'relativeUnit': _$PollTimeUnitEnumMap[instance.relativeUnit],
};

const _$PollModeEnumMap = {
  PollMode.permanent: 'permanent',
  PollMode.date: 'date',
  PollMode.relative: 'relative',
};

const _$PollTimeUnitEnumMap = {
  PollTimeUnit.seconds: 'seconds',
  PollTimeUnit.minutes: 'minutes',
  PollTimeUnit.hours: 'hours',
  PollTimeUnit.days: 'days',
};

_PollResult _$PollResultFromJson(Map<String, dynamic> json) => _PollResult(
  choices: (json['choices'] as List<dynamic>)
      .map((e) => PollChoiceResult.fromJson(e as Map<String, dynamic>))
      .toList(),
  multiple: json['multiple'] as bool? ?? false,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  votesCount: (json['votesCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PollResultToJson(_PollResult instance) =>
    <String, dynamic>{
      'choices': instance.choices,
      'multiple': instance.multiple,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'votesCount': instance.votesCount,
    };

_PollChoiceResult _$PollChoiceResultFromJson(Map<String, dynamic> json) =>
    _PollChoiceResult(
      text: json['text'] as String,
      votes: (json['votes'] as num).toInt(),
      isVoted: json['isVoted'] as bool? ?? false,
    );

Map<String, dynamic> _$PollChoiceResultToJson(_PollChoiceResult instance) =>
    <String, dynamic>{
      'text': instance.text,
      'votes': instance.votes,
      'isVoted': instance.isVoted,
    };

_PollTimeSetting _$PollTimeSettingFromJson(Map<String, dynamic> json) =>
    _PollTimeSetting(
      mode: $enumDecode(_$PollModeEnumMap, json['mode']),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      relativeValue: (json['relativeValue'] as num?)?.toInt(),
      relativeUnit: $enumDecodeNullable(
        _$PollTimeUnitEnumMap,
        json['relativeUnit'],
      ),
    );

Map<String, dynamic> _$PollTimeSettingToJson(_PollTimeSetting instance) =>
    <String, dynamic>{
      'mode': _$PollModeEnumMap[instance.mode]!,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'relativeValue': instance.relativeValue,
      'relativeUnit': _$PollTimeUnitEnumMap[instance.relativeUnit],
    };
