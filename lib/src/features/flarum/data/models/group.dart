class Group {
  final String id;
  final String nameSingular;
  final String namePlural;
  final String? color;
  final String? icon;

  Group({
    required this.id,
    required this.nameSingular,
    required this.namePlural,
    this.color,
    this.icon,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    return Group(
      id: json['id'] ?? '',
      nameSingular: attributes['nameSingular'] ?? '',
      namePlural: attributes['namePlural'] ?? '',
      color: attributes['color'],
      icon: attributes['icon'],
    );
  }
}
