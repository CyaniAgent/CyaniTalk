import 'package:freezed_annotation/freezed_annotation.dart';

part 'emoji.freezed.dart';
part 'emoji.g.dart';

@freezed
abstract class Emoji with _$Emoji {
  const factory Emoji({
    required List<String> aliases,
    required String name,
    String? category,
    required String url,
  }) = _Emoji;

  factory Emoji.fromJson(Map<String, dynamic> json) => _$EmojiFromJson(json);
}

@freezed
abstract class EmojiDetail with _$EmojiDetail {
  const factory EmojiDetail({
    required String id,
    required List<String> aliases,
    required String name,
    String? category,
    String? host,
    required String url,
    String? license,
    @Default(false) bool isSensitive,
    @Default(false) bool localOnly,
    @Default([]) List<String> roleIdsThatCanBeUsedThisEmojiAsReaction,
  }) = _EmojiDetail;

  factory EmojiDetail.fromJson(Map<String, dynamic> json) =>
      _$EmojiDetailFromJson(json);
}

@freezed
abstract class EmojisResponse with _$EmojisResponse {
  const factory EmojisResponse({required List<Emoji> emojis}) = _EmojisResponse;

  factory EmojisResponse.fromJson(Map<String, dynamic> json) =>
      _$EmojisResponseFromJson(json);
}
