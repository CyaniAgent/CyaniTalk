import 'package:freezed_annotation/freezed_annotation.dart';
import 'group.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String username,
    required String displayName,
    String? avatarUrl,
    required String slug,
    required String joinTime,
    required int discussionCount,
    required int commentCount,
    required bool canEdit,
    required bool canEditCredentials,
    required bool canEditGroups,
    required bool canDelete,
    String? lastSeenAt,
    required bool isEmailConfirmed,
    required bool isAdmin,
    required Map<String, dynamic> preferences,
    @Default([]) List<Group> groups,
  }) = _User;

  factory User.fromJson(
    Map<String, dynamic> json, {
    List<dynamic> included = const [],
  }) {
    final attrs = json['attributes'] ?? {};
    final relationships = json['relationships'] ?? {};

    // Parse Groups
    List<Group> parsedGroups = [];
    if (relationships['groups'] != null &&
        relationships['groups']['data'] != null) {
      final groupData = relationships['groups']['data'] as List;
      final groupIds = groupData.map((g) => g['id']).toSet();

      final includedGroups = included.where(
        (item) => item['type'] == 'groups' && groupIds.contains(item['id']),
      );

      parsedGroups = includedGroups.map((g) => Group.fromJson(g)).toList();
    }

    return User(
      id: json['id'] as String? ?? '',
      username: attrs['username'] as String? ?? 'unknown',
      displayName:
          attrs['displayName'] as String? ??
          attrs['username'] as String? ??
          'User',
      avatarUrl: attrs['avatarUrl'] as String?,
      slug: attrs['slug'] as String? ?? '',
      joinTime:
          attrs['joinTime'] as String? ?? DateTime.now().toIso8601String(),
      discussionCount: attrs['discussionCount'] as int? ?? 0,
      commentCount: attrs['commentCount'] as int? ?? 0,
      canEdit: attrs['canEdit'] as bool? ?? false,
      canEditCredentials: attrs['canEditCredentials'] as bool? ?? false,
      canEditGroups: attrs['canEditGroups'] as bool? ?? false,
      canDelete: attrs['canDelete'] as bool? ?? false,
      lastSeenAt: attrs['lastSeenAt'] as String?,
      isEmailConfirmed: attrs['isEmailConfirmed'] as bool? ?? false,
      isAdmin: attrs['isAdmin'] as bool? ?? false,
      preferences: attrs['preferences'] as Map<String, dynamic>? ?? {},
      groups: parsedGroups,
    );
  }
}
