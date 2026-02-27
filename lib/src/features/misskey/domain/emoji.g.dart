// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Emoji _$EmojiFromJson(Map<String, dynamic> json) => _Emoji(
  aliases: (json['aliases'] as List<dynamic>).map((e) => e as String).toList(),
  name: json['name'] as String,
  category: json['category'] as String?,
  url: json['url'] as String,
);

Map<String, dynamic> _$EmojiToJson(_Emoji instance) => <String, dynamic>{
  'aliases': instance.aliases,
  'name': instance.name,
  'category': instance.category,
  'url': instance.url,
};

_EmojiDetail _$EmojiDetailFromJson(Map<String, dynamic> json) => _EmojiDetail(
  id: json['id'] as String,
  aliases: (json['aliases'] as List<dynamic>).map((e) => e as String).toList(),
  name: json['name'] as String,
  category: json['category'] as String?,
  host: json['host'] as String?,
  url: json['url'] as String,
  license: json['license'] as String?,
  isSensitive: json['isSensitive'] as bool? ?? false,
  localOnly: json['localOnly'] as bool? ?? false,
  roleIdsThatCanBeUsedThisEmojiAsReaction:
      (json['roleIdsThatCanBeUsedThisEmojiAsReaction'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$EmojiDetailToJson(_EmojiDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'aliases': instance.aliases,
      'name': instance.name,
      'category': instance.category,
      'host': instance.host,
      'url': instance.url,
      'license': instance.license,
      'isSensitive': instance.isSensitive,
      'localOnly': instance.localOnly,
      'roleIdsThatCanBeUsedThisEmojiAsReaction':
          instance.roleIdsThatCanBeUsedThisEmojiAsReaction,
    };

_EmojisResponse _$EmojisResponseFromJson(Map<String, dynamic> json) =>
    _EmojisResponse(
      emojis: (json['emojis'] as List<dynamic>)
          .map((e) => Emoji.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EmojisResponseToJson(_EmojisResponse instance) =>
    <String, dynamic>{'emojis': instance.emojis};
