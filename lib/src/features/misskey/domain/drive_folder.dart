import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_folder.freezed.dart';
part 'drive_folder.g.dart';

@freezed
abstract class DriveFolder with _$DriveFolder {
  const factory DriveFolder({
    required String id,
    required DateTime createdAt,
    required String name,
    String? parentId,
  }) = _DriveFolder;

  factory DriveFolder.fromJson(Map<String, dynamic> json) =>
      _$DriveFolderFromJson(json);
}
