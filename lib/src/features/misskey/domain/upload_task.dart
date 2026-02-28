import 'package:freezed_annotation/freezed_annotation.dart';
import 'drive_file.dart';

part 'upload_task.freezed.dart';
part 'upload_task.g.dart';

/// 上传任务状态枚举
enum UploadStatus {
  /// 等待上传
  pending,

  /// 上传中
  uploading,

  /// 上传成功
  success,

  /// 上传失败
  failed,

  /// 重试中
  retrying,
}

/// 上传任务数据模型
///
/// 用于管理文件上传过程中的状态、进度和相关信息
@freezed
abstract class UploadTask with _$UploadTask {
  const factory UploadTask({
    /// 任务唯一标识
    required String id,

    /// 文件名
    required String fileName,

    /// 文件大小（字节）
    required int fileSize,

    /// 文件类型（mime 类型或扩展名）
    required String fileType,

    /// 当前上传状态
    required UploadStatus status,

    /// 上传进度（0.0-1.0）
    double? progress,

    /// 上传成功的文件信息
    DriveFile? file,

    /// 错误信息（失败时使用）
    String? error,
  }) = _UploadTask;

  factory UploadTask.fromJson(Map<String, dynamic> json) =>
      _$UploadTaskFromJson(json);

  /// 创建等待上传的任务
  static UploadTask pending({
    required String id,
    required String fileName,
    required int fileSize,
    required String fileType,
  }) {
    return UploadTask(
      id: id,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      status: UploadStatus.pending,
      progress: 0.0,
    );
  }

  /// 创建上传中的任务
  static UploadTask uploading({
    required String id,
    required String fileName,
    required int fileSize,
    required String fileType,
    double? progress,
  }) {
    return UploadTask(
      id: id,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      status: UploadStatus.uploading,
      progress: progress ?? 0.0,
    );
  }

  /// 创建上传成功的任务
  static UploadTask success({
    required String id,
    required String fileName,
    required int fileSize,
    required String fileType,
    required DriveFile file,
  }) {
    return UploadTask(
      id: id,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      status: UploadStatus.success,
      progress: 1.0,
      file: file,
    );
  }

  /// 创建上传失败的任务
  static UploadTask failed({
    required String id,
    required String fileName,
    required int fileSize,
    required String fileType,
    required String error,
  }) {
    return UploadTask(
      id: id,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      status: UploadStatus.failed,
      progress: 0.0,
      error: error,
    );
  }

  /// 创建重试中的任务
  static UploadTask retrying({
    required String id,
    required String fileName,
    required int fileSize,
    required String fileType,
    double? progress,
  }) {
    return UploadTask(
      id: id,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      status: UploadStatus.retrying,
      progress: progress,
    );
  }
}