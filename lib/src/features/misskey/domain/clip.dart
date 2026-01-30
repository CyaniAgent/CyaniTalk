import 'package:freezed_annotation/freezed_annotation.dart';
import 'misskey_user.dart';

part 'clip.freezed.dart';
part 'clip.g.dart';

@freezed
abstract class Clip with _$Clip {
  const factory Clip({
    required String id,
    required DateTime createdAt,
    DateTime? lastClippedAt,
    required String userId,
    required MisskeyUser user,
    required String name,
    String? description,
    @Default(false) bool isPublic,
    @Default(0) int favoritedCount,
    @Default(0) int notesCount,
  }) = _Clip;

  factory Clip.fromJson(Map<String, dynamic> json) => _$ClipFromJson(json);
}
