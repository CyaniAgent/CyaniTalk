import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_file.freezed.dart';
part 'drive_file.g.dart';

@freezed
abstract class DriveFile with _$DriveFile {
  const factory DriveFile({
    required String id,
    required DateTime createdAt,
    required String name,
    required String type,
    required int size,
    required String url,
    String? thumbnailUrl,
    String? blurhash,
    @Default(false) bool isSensitive,
    String? folderId,
  }) = _DriveFile;

  factory DriveFile.fromJson(Map<String, dynamic> json) =>
      _$DriveFileFromJson(json);
}
