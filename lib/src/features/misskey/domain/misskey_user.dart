import 'package:freezed_annotation/freezed_annotation.dart';

part 'misskey_user.freezed.dart';
part 'misskey_user.g.dart';

@freezed
abstract class MisskeyUser with _$MisskeyUser {
  const factory MisskeyUser({
    required String id,
    String? name,
    required String username,
    String? host,
    String? avatarUrl,
    String? bannerUrl,
    String? description,
    DateTime? createdAt,
    int? notesCount,
    int? followingCount,
    int? followersCount,
    @Default([]) List<Map<String, dynamic>> badgeRoles,
    @Default([]) List<Map<String, dynamic>> roles,
    @Default(false) bool isAdmin,
    @Default(false) bool isModerator,
    @Default(false) bool isBot,
    @Default(false) bool isCat,
    int? driveCapacityMb,
    int? driveUsage,
    Map<String, String>? emojis,
  }) = _MisskeyUser;

  factory MisskeyUser.fromJson(Map<String, dynamic> json) =>
      _$MisskeyUserFromJson(json);
}
