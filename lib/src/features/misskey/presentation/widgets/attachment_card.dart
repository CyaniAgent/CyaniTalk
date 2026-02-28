import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/domain/upload_task.dart';

/// 附件卡片组件
///
/// 用于显示单个上传附件的卡片，支持显示上传进度、状态和操作按钮
class AttachmentCard extends StatelessWidget {
  final UploadTask task;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;
  final bool isUploading;

  const AttachmentCard({
    super.key,
    required this.task,
    this.onRemove,
    this.onRetry,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Stack(
          children: [
            // 主体内容
            _buildContent(context),
            
            // 移除按钮
            if (task.status == UploadStatus.success || 
                task.status == UploadStatus.failed)
              Positioned(
                top: 4,
                right: 4,
                child: _buildRemoveButton(context),
              ),
            
            // 重试按钮
            if (task.status == UploadStatus.failed)
              Positioned(
                bottom: 4,
                right: 4,
                child: _buildRetryButton(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (task.status) {
      case UploadStatus.pending:
      case UploadStatus.uploading:
      case UploadStatus.retrying:
        return _buildUploadingContent(context);
      
      case UploadStatus.success:
        return _buildSuccessContent(context);
      
      case UploadStatus.failed:
        return _buildFailedContent(context);
    }
  }

  /// 上传中的内容
  Widget _buildUploadingContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 文件类型图标
          Expanded(
            child: Center(
              child: _buildFileTypeIcon(size: 40),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 文件名（截断显示）
          Text(
            task.fileName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // 进度条
          if (task.status == UploadStatus.uploading) ...[
            LinearProgressIndicator(
              value: task.progress ?? 0.0,
              minHeight: 3,
            ),
            const SizedBox(height: 4),
            Text(
              '${((task.progress ?? 0.0) * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ] else if (task.status == UploadStatus.pending) ...[
            Text(
              'attachment_pending'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ] else if (task.status == UploadStatus.retrying) ...[
            Text(
              'attachment_retrying'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 上传成功的内容
  Widget _buildSuccessContent(BuildContext context) {
    final file = task.file;
    if (file == null) {
      return _buildUploadingContent(context);
    }

    // 获取图片 URL（优先缩略图，其次原图）
    final imageUrl = file.thumbnailUrl ?? file.url;
    
    return Stack(
      children: [
        // 如果是图片，显示缩略图
        if (_isImage(task.fileType))
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFileTypeIcon(size: 60);
              },
            ),
          )
        else
          Positioned.fill(
            child: Center(
              child: _buildFileTypeIcon(size: 60),
            ),
          ),
        
        // 成功标记
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// 上传失败的内容
  Widget _buildFailedContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: _buildFileTypeIcon(size: 40),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 错误信息
          Text(
            task.error ?? 'attachment_upload_failed'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: Theme.of(context).colorScheme.error,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeIcon({double size = 40}) {
    return FileTypeIcon(
      fileType: task.fileType,
      size: size,
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onRemove,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onRetry,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.refresh,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  bool _isImage(String fileType) {
    return fileType.startsWith('image/');
  }
}

/// 文件类型图标组件
///
/// 根据文件类型显示对应的图标
class FileTypeIcon extends StatelessWidget {
  final String fileType;
  final double size;

  const FileTypeIcon({
    super.key,
    required this.fileType,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconForFileType(fileType),
      size: size,
      color: _getColorForFileType(context),
    );
  }

  IconData _getIconForFileType(String fileType) {
    if (fileType.startsWith('image/')) {
      return Icons.image;
    } else if (fileType.startsWith('video/')) {
      return Icons.videocam;
    } else if (fileType.startsWith('audio/')) {
      return Icons.music_note;
    } else if (fileType == 'application/pdf') {
      return Icons.picture_as_pdf;
    } else if (fileType.startsWith('text/')) {
      return Icons.description;
    } else if (fileType.contains('zip') || 
               fileType.contains('compressed') ||
               fileType == 'application/x-rar-compressed' ||
               fileType == 'application/x-7z-compressed') {
      return Icons.folder_zip;
    } else {
      return Icons.insert_drive_file;
    }
  }

  Color _getColorForFileType(BuildContext context) {
    if (fileType.startsWith('image/')) {
      return Colors.purple;
    } else if (fileType.startsWith('video/')) {
      return Colors.red;
    } else if (fileType.startsWith('audio/')) {
      return Colors.orange;
    } else if (fileType == 'application/pdf') {
      return Colors.red.shade700;
    } else if (fileType.startsWith('text/')) {
      return Colors.blue;
    } else if (fileType.contains('zip') || fileType.contains('compressed')) {
      return Colors.amber;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }
}
