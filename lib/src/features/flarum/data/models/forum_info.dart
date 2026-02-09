import 'package:freezed_annotation/freezed_annotation.dart';

part 'forum_info.freezed.dart';

@freezed
abstract class ForumInfo with _$ForumInfo {
  const factory ForumInfo({
    required String title,
    required String description,
    required String baseUrl,
    String? logoUrl,
    String? faviconUrl,
    required String welcomeTitle,
    required String welcomeMessage,
    required bool allowSignUp,
  }) = _ForumInfo;

  factory ForumInfo.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? json;

    return ForumInfo(
      title: attributes['title'] ?? '',
      description: attributes['description'] ?? '',
      baseUrl: attributes['baseUrl'] ?? '',
      logoUrl: attributes['logoUrl'] as String?,
      faviconUrl: attributes['faviconUrl'] as String?,
      welcomeTitle: attributes['welcomeTitle'] ?? '',
      welcomeMessage: attributes['welcomeMessage'] ?? '',
      allowSignUp: attributes['allowSignUp'] ?? false,
    );
  }
}
