class ForumInfo {
  final String title;
  final String description;
  final String baseUrl;
  final String? logoUrl;
  final String? faviconUrl;
  final String welcomeTitle;
  final String welcomeMessage;
  final bool allowSignUp;

  ForumInfo({
    required this.title,
    required this.description,
    required this.baseUrl,
    this.logoUrl,
    this.faviconUrl,
    required this.welcomeTitle,
    required this.welcomeMessage,
    required this.allowSignUp,
  });

  factory ForumInfo.fromJson(Map<String, dynamic> json) {
    // Top-level "data" object in JSON:API usually contains attributes directly for the forum info endpoint
    // But typically GET /api returns an object where attributes are at the top level or under 'data' if it's a resource.
    // Flarum's GET /api returns a payload where 'attributes' contains title, description etc.
    // Assuming the json passed here is the 'attributes' map or the root object containing attributes.

    // In Flarum GET /api, the root object has "data" which is an object with "attributes".
    // But commonly we might pass just the attributes map if we parse it before.
    // Let's assume we pass the 'attributes' map here for simplicity, or handle both.

    final attributes = json['attributes'] ?? json;

    return ForumInfo(
      title: attributes['title'] ?? '',
      description: attributes['description'] ?? '',
      baseUrl: attributes['baseUrl'] ?? '', // Flarum API might return this
      logoUrl: attributes['logoUrl'],
      faviconUrl: attributes['faviconUrl'],
      welcomeTitle: attributes['welcomeTitle'] ?? '',
      welcomeMessage: attributes['welcomeMessage'] ?? '',
      allowSignUp: attributes['allowSignUp'] ?? false,
    );
  }
}
