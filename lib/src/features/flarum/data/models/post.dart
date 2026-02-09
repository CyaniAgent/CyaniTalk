import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    required int number,
    required String createdAt,
    required String contentType,
    required String contentHtml,
    required bool renderFailed,
    required String discussionId,
    required String userId,
    @Default([]) List<String> tagIds,
  }) = _Post;

  factory Post.fromJson(
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

    return Post(
      id: json['id'] as String? ?? '',
      number: attrs['number'] as int? ?? 0,
      createdAt: attrs['createdAt'] as String? ?? '',
      contentType: attrs['contentType'] as String? ?? '',
      contentHtml: attrs['contentHtml'] as String? ?? '<p></p>',
      renderFailed: attrs['renderFailed'] as bool? ?? false,
      discussionId: rels['discussion']?['data']?['id'] as String? ?? 'unknown',
      userId: rels['user']?['data']?['id'] as String? ?? 'unknown',
      tagIds: tagIds,
    );
  }
}
