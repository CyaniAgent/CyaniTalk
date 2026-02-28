// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadTask _$UploadTaskFromJson(Map<String, dynamic> json) => _UploadTask(
  id: json['id'] as String,
  fileName: json['fileName'] as String,
  fileSize: (json['fileSize'] as num).toInt(),
  fileType: json['fileType'] as String,
  status: $enumDecode(_$UploadStatusEnumMap, json['status']),
  progress: (json['progress'] as num?)?.toDouble(),
  file: json['file'] == null
      ? null
      : DriveFile.fromJson(json['file'] as Map<String, dynamic>),
  error: json['error'] as String?,
);

Map<String, dynamic> _$UploadTaskToJson(_UploadTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'fileType': instance.fileType,
      'status': _$UploadStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'file': instance.file,
      'error': instance.error,
    };

const _$UploadStatusEnumMap = {
  UploadStatus.pending: 'pending',
  UploadStatus.uploading: 'uploading',
  UploadStatus.success: 'success',
  UploadStatus.failed: 'failed',
  UploadStatus.retrying: 'retrying',
};
