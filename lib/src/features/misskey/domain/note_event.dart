import 'note.dart';

/// Misskey 串流笔记事件
class NoteEvent {
  /// 接收到的新笔记（如果是创建事件）
  final Note? note;

  /// 时间线类型（仅针对时间线更新）
  final String? timelineType;

  /// 笔记 ID（如果是删除事件）
  final String? noteId;

  /// 是否为删除事件
  final bool isDelete;

  NoteEvent({this.note, this.timelineType, this.noteId, this.isDelete = false});

  /// 创建一个笔记删除事件
  factory NoteEvent.deleted(String noteId) =>
      NoteEvent(noteId: noteId, isDelete: true);

  /// 创建一个新笔记事件
  factory NoteEvent.created(Note note, String timelineType) =>
      NoteEvent(note: note, timelineType: timelineType);
}
