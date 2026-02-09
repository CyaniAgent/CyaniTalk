import 'package:freezed_annotation/freezed_annotation.dart';

part 'discussion.freezed.dart';

@freezed
abstract class Discussion with _$Discussion {
  const factory Discussion({
    required String id,
    required String title,
    required String slug,
    required int commentCount,
    required int participantCount,
    required String createdAt,
    required String lastPostedAt,
    required int lastPostNumber,
    required bool canReply,
    required bool canRename,
    required bool canDelete,
    required bool canHide,
    required bool isHidden,
    required bool isLocked,
    required bool isSticky,
    String? subscription,
    required String userId,
    required String lastPostedUserId,
    @Default([]) List<String> tagIds,
    required String firstPostId,
  }) = _Discussion;

  factory Discussion.fromJson(
    Map<String, dynamic> json, {
    List<dynamic> included = const [],
  }) {
    final attrs = json['attributes'] ?? {};
    final rels = json['relationships'] ?? {};

    List<String> tagIds = [];
    if (rels['tags'] != null && rels['tags']['data'] is List) {
      tagIds = (rels['tags']['data'] as List)
          .map((tag) => tag['id'] as String)
          .toList();
    }

    return Discussion(
      id: json['id'] as String? ?? '',
      title: attrs['title'] as String? ?? '',
      slug: attrs['slug'] as String? ?? '',
      commentCount: attrs['commentCount'] as int? ?? 0,
      participantCount: attrs['participantCount'] as int? ?? 0,
      createdAt: attrs['createdAt'] as String? ?? '',
      lastPostedAt: attrs['lastPostedAt'] as String? ?? '',
      lastPostNumber: attrs['lastPostNumber'] as int? ?? 0,
      canReply: attrs['canReply'] as bool? ?? true,
      canRename: attrs['canRename'] as bool? ?? false,
      canDelete: attrs['canDelete'] as bool? ?? false,
      canHide: attrs['canHide'] as bool? ?? false,
      isHidden: attrs['isHidden'] as bool? ?? false,
      isLocked: attrs['isLocked'] as bool? ?? false,
      isSticky: attrs['isSticky'] as bool? ?? false,
      subscription: attrs['subscription'] as String?,
      userId: rels['user']?['data']?['id'] as String? ?? 'unknown',
      lastPostedUserId:
          rels['lastPostedUser']?['data']?['id'] as String? ?? 'unknown',
      tagIds: tagIds,
      firstPostId: rels['firstPost']?['data']?['id'] as String? ?? 'unknown',
    );
  }
}
