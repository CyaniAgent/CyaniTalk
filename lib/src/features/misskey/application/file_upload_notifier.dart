import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/features/misskey/domain/upload_task.dart';
import '/src/features/misskey/domain/drive_file.dart';

part 'file_upload_notifier.g.dart';

/// 文件上传状态管理类
///
/// 用于管理文件上传队列、进度和状态
@riverpod
class FileUpload extends _$FileUpload {
  final _uuid = const Uuid();

  @override
  List<UploadTask> build() {
    return [];
  }

  /// 添加本地文件到上传队列
  void addLocalFile(File file) {
    final taskId = _uuid.v4();
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = file.lengthSync();
    final fileType = _getMimeType(fileName);

    final task = UploadTask.pending(
      id: taskId,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
    );

    state = [...state, task];
    
    // 开始上传
    _uploadFile(task, file);
  }

  /// 添加字节数据到上传队列（用于从其他来源获取的文件）
  void addFileBytes(
    List<int> bytes,
    String fileName,
    String fileType,
  ) {
    final taskId = _uuid.v4();
    final fileSize = bytes.length;

    final task = UploadTask.pending(
      id: taskId,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
    );

    state = [...state, task];
    
    // 开始上传
    _uploadBytes(task, bytes);
  }

  /// 移除上传任务
  void removeTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  /// 清除所有已完成的任务
  void clearCompletedTasks() {
    state = state.where((task) => 
      task.status != UploadStatus.success && 
      task.status != UploadStatus.failed
    ).toList();
  }

  /// 获取所有已上传成功的文件 ID 列表
  List<String> getUploadedFileIds() {
    return state
        .where((task) => task.status == UploadStatus.success && task.file != null)
        .map((task) => task.file!.id)
        .toList();
  }

  /// 获取所有已上传成功的文件信息
  List<DriveFile> getUploadedFiles() {
    return state
        .where((task) => task.status == UploadStatus.success && task.file != null)
        .map((task) => task.file!)
        .toList();
  }

  /// 重试失败的任务
  void retryTask(String taskId) {
    final taskIndex = state.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    final task = state[taskIndex];
    final updatedTask = task.copyWith(
      status: UploadStatus.retrying,
      progress: 0.0,
      error: null,
    );

    state = [
      ...state.sublist(0, taskIndex),
      updatedTask,
      ...state.sublist(taskIndex + 1),
    ];

    // 重新上传
    if (task.file != null) {
      _reuploadTask(task);
    }
  }

  /// 获取当前上传中的任务数量
  int get uploadingCount {
    return state.where((task) => task.status == UploadStatus.uploading).length;
  }

  /// 获取失败的任务数量
  int get failedCount {
    return state.where((task) => task.status == UploadStatus.failed).length;
  }

  /// 获取总的任务数量
  int get totalCount => state.length;

  /// 获取整体上传进度（0.0-1.0）
  double get overallProgress {
    if (state.isEmpty) return 0.0;
    
    final totalProgress = state.fold<double>(
      0.0,
      (sum, task) => sum + (task.progress ?? 0.0),
    );
    
    return totalProgress / state.length;
  }

  /// 上传文件（从 File 对象）
  Future<void> _uploadFile(UploadTask task, File file) async {
    try {
      final taskIndex = state.indexWhere((t) => t.id == task.id);
      if (taskIndex == -1) return;

      // 更新状态为上传中
      state = [
        ...state.sublist(0, taskIndex),
        task.copyWith(status: UploadStatus.uploading, progress: 0.0),
        ...state.sublist(taskIndex + 1),
      ];

      // 读取文件字节
      final bytes = await file.readAsBytes();
      
      // 执行上传
      await _uploadBytes(
        state[taskIndex],
        bytes,
      );
    } catch (e) {
      _handleUploadError(task, e);
    }
  }

  /// 上传字节数据
  Future<void> _uploadBytes(UploadTask task, List<int> bytes) async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      
      // 监听上传进度（这里简化处理，实际应该使用 stream）
      final uploadedFile = await repository.uploadDriveFile(
        bytes,
        task.fileName,
      );

      // 更新状态为成功
      final taskIndex = state.indexWhere((t) => t.id == task.id);
      if (taskIndex == -1) return;

      state = [
        ...state.sublist(0, taskIndex),
        UploadTask.success(
          id: task.id,
          fileName: task.fileName,
          fileSize: task.fileSize,
          fileType: task.fileType,
          file: uploadedFile,
        ),
        ...state.sublist(taskIndex + 1),
      ];
    } catch (e) {
      _handleUploadError(task, e);
    }
  }

  /// 重新上传任务
  Future<void> _reuploadTask(UploadTask task) async {
    // 这里需要从云盘或其他来源重新获取文件数据
    // 暂时简化处理，直接标记为失败
    final taskIndex = state.indexWhere((t) => t.id == task.id);
    if (taskIndex == -1) return;

    state = [
      ...state.sublist(0, taskIndex),
      task.copyWith(
        status: UploadStatus.failed,
        error: '需要实现重新上传逻辑',
      ),
      ...state.sublist(taskIndex + 1),
    ];
  }

  /// 处理上传错误
  void _handleUploadError(UploadTask task, Object error) {
    final taskIndex = state.indexWhere((t) => t.id == task.id);
    if (taskIndex == -1) return;

    state = [
      ...state.sublist(0, taskIndex),
      UploadTask.failed(
        id: task.id,
        fileName: task.fileName,
        fileSize: task.fileSize,
        fileType: task.fileType,
        error: error.toString(),
      ),
      ...state.sublist(taskIndex + 1),
    ];
  }

  /// 获取文件类型
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case '7z':
        return 'application/x-7z-compressed';
      default:
        return 'application/octet-stream';
    }
  }
}
