class User {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String slug;
  final String joinTime;
  final int discussionCount;
  final int commentCount;
  final bool canEdit;
  final bool canEditCredentials;
  final bool canEditGroups;
  final bool canDelete;
  final String? lastSeenAt;
  final bool isEmailConfirmed;
  final bool isAdmin;
  final Map<String, dynamic> preferences;

  User({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.slug,
    required this.joinTime,
    required this.discussionCount,
    required this.commentCount,
    required this.canEdit,
    required this.canEditCredentials,
    required this.canEditGroups,
    required this.canDelete,
    this.lastSeenAt,
    required this.isEmailConfirmed,
    required this.isAdmin,
    required this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] ?? {};
    return User(
      id: json['id'] ?? '',
      username: attrs['username'] ?? 'unknown',
      displayName: attrs['displayName'] ?? attrs['username'] ?? 'User',
      avatarUrl: attrs['avatarUrl'],
      slug: attrs['slug'] ?? '',
      joinTime: attrs['joinTime'] ?? DateTime.now().toIso8601String(),
      discussionCount: attrs['discussionCount'] ?? 0,
      commentCount: attrs['commentCount'] ?? 0,
      canEdit: attrs['canEdit'] ?? false,
      canEditCredentials: attrs['canEditCredentials'] ?? false,
      canEditGroups: attrs['canEditGroups'] ?? false,
      canDelete: attrs['canDelete'] ?? false,
      lastSeenAt: attrs['lastSeenAt'],
      isEmailConfirmed: attrs['isEmailConfirmed'] ?? false,
      isAdmin: attrs['isAdmin'] ?? false,
      preferences: attrs['preferences'] ?? {},
    );
  }
}
