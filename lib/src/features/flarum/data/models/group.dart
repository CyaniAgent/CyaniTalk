import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';

@freezed
abstract class Group with _$Group {
  const factory Group({
    required String id,
    required String nameSingular,
    required String namePlural,
    String? color,
    String? icon,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('attributes')) {
      final attributes = json['attributes'] as Map<String, dynamic>;
      return Group(
        id: json['id'] as String? ?? '',
        nameSingular: attributes['nameSingular'] as String? ?? '',
        namePlural: attributes['namePlural'] as String? ?? '',
        color: attributes['color'] as String?,
        icon: attributes['icon'] as String?,
      );
    }
    // Fallback for direct attribute maps or generated code
    return Group(
      id: json['id'] as String? ?? '',
      nameSingular: json['nameSingular'] as String? ?? '',
      namePlural: json['namePlural'] as String? ?? '',
      color: json['color'] as String?,
      icon: json['icon'] as String?,
    );
  }
}
