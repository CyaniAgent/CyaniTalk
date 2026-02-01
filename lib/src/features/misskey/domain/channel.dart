import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel.freezed.dart';
part 'channel.g.dart';

enum MisskeyChannelListType {
  featured,
  favorites,
  following,
  managing,
  search,
}

@freezed
abstract class Channel with _$Channel {
  const factory Channel({
    required String id,
    required DateTime createdAt,
    DateTime? lastNotedAt,
    required String name,
    String? description,
    String? userId,
    String? bannerUrl,
    @Default([]) List<String> pinnedNoteIds,
    @Default("") String color,
    @Default(false) bool isArchived,
    @Default(0) int usersCount,
    @Default(0) int notesCount,
    @Default(false) bool isSensitive,
    @Default(true) bool allowRenoteToExternal,
    bool? isFollowing,
    bool? isFavorited,
  }) = _Channel;

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}
