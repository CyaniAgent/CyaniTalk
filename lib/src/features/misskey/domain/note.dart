import 'package:freezed_annotation/freezed_annotation.dart';
import 'misskey_user.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
abstract class Note with _$Note {
  const factory Note({
    required String id,
    required DateTime createdAt,
    String? userId,
    MisskeyUser? user,
    String? text,
    String? cw,
    @Default([]) List<String> fileIds,
    @Default([]) List<Map<String, dynamic>> files,
    String? replyId,
    String? renoteId,
    Note? reply,
    Note? renote,
    @Default({}) Map<String, int> reactions,
    @Default(0) int renoteCount,
    @Default(0) int repliesCount,
    String? visibility,
    @Default(false) bool localOnly,
    String? myReaction,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
