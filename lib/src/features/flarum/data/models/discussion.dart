class Discussion {
  final String id;
  final String title;
  final String slug;
  final int commentCount;
  final int participantCount;
  final String createdAt;
  final String lastPostedAt;
  final int lastPostNumber;
  final bool canReply;
  final bool canRename;
  final bool canDelete;
  final bool canHide;
  final bool isHidden;
  final bool isLocked;
  final bool isSticky;
  final String? subscription;
  final String userId;
  final String lastPostedUserId;
  final List<String> tagIds;
  final String firstPostId;

  Discussion({
    required this.id,
    required this.title,
    required this.slug,
    required this.commentCount,
    required this.participantCount,
    required this.createdAt,
    required this.lastPostedAt,
    required this.lastPostNumber,
    required this.canReply,
    required this.canRename,
    required this.canDelete,
    required this.canHide,
    required this.isHidden,
    required this.isLocked,
    required this.isSticky,
    this.subscription,
    required this.userId,
    required this.lastPostedUserId,
    required this.tagIds,
    required this.firstPostId,
  });

  factory Discussion.fromJson(Map<String, dynamic> json) {
    return Discussion(
      id: json['id'],
      title: json['attributes']['title'],
      slug: json['attributes']['slug'],
      commentCount: json['attributes']['commentCount'],
      participantCount: json['attributes']['participantCount'],
      createdAt: json['attributes']['createdAt'],
      lastPostedAt: json['attributes']['lastPostedAt'],
      lastPostNumber: json['attributes']['lastPostNumber'],
      canReply: json['attributes']['canReply'] ?? true,
      canRename: json['attributes']['canRename'] ?? false,
      canDelete: json['attributes']['canDelete'] ?? false,
      canHide: json['attributes']['canHide'] ?? false,
      isHidden: json['attributes']['isHidden'] ?? false,
      isLocked: json['attributes']['isLocked'] ?? false,
      isSticky: json['attributes']['isSticky'] ?? false,
      subscription: json['attributes']['subscription'],
      userId: json['relationships']['user']?['data']?['id'] ?? 'unknown',
      lastPostedUserId:
          json['relationships']['lastPostedUser']?['data']?['id'] ?? 'unknown',
      tagIds: (json['relationships']['tags']?['data'] as List? ?? [])
          .map((tag) => tag['id'] as String)
          .toList(),
      firstPostId:
          json['relationships']['firstPost']?['data']?['id'] ?? 'unknown',
    );
  }
}
