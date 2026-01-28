class FlarumNotification {
  final String id;
  final String type;
  final String? contentType;
  final String? content;
  final bool isRead;
  final String createdAt;
  final String? fromUserId;
  final String? subjectId;
  final String? subjectType;

  FlarumNotification({
    required this.id,
    required this.type,
    this.contentType,
    this.content,
    required this.isRead,
    required this.createdAt,
    this.fromUserId,
    this.subjectId,
    this.subjectType,
  });

  factory FlarumNotification.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? {};
    final rels = json['relationships'] ?? {};

    return FlarumNotification(
      id: json['id'],
      type: attrs['type'] ?? 'unknown',
      contentType: attrs['contentType'],
      content: attrs['content'],
      isRead: attrs['isRead'] ?? false,
      createdAt: attrs['createdAt'] ?? '',
      fromUserId: rels['fromUser']?['data']?['id'],
      subjectId: rels['subject']?['data']?['id'],
      subjectType: rels['subject']?['data']?['type'],
    );
  }
}
