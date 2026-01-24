class Post {
  final String id;
  final int number;
  final String createdAt;
  final String contentType;
  final String contentHtml;
  final bool renderFailed;
  final String discussionId;
  final String userId;
  final List<String> tagIds;

  Post({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.contentType,
    required this.contentHtml,
    required this.renderFailed,
    required this.discussionId,
    required this.userId,
    required this.tagIds,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<String> tagIds = [];
    if (json.containsKey('relationships') &&
        json['relationships'].containsKey('tags')) {
      final tagsData = json['relationships']['tags']['data'];
      if (tagsData is List) {
        tagIds = tagsData.map((tag) => tag['id'] as String).toList();
      }
    }

    return Post(
      id: json['id'],
      number: json['attributes']['number'],
      createdAt: json['attributes']['createdAt'],
      contentType: json['attributes']['contentType'],
      contentHtml: json['attributes']['contentHtml'] ?? '<p></p>',
      renderFailed: json['attributes']['renderFailed'] ?? false,
      discussionId: json['relationships']['discussion']['data']['id'],
      userId: json['relationships']['user']['data']['id'],
      tagIds: tagIds,
    );
  }
}
