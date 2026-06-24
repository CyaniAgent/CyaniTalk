import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '/src/features/misskey/application/drive_notifier.dart';
import '/src/core/utils/download_utils.dart';

enum _UploadStatus { pending, uploading, completed, failed }

class _UploadItem {
  final String name;
  final String path;
  final int size;
  _UploadStatus status = _UploadStatus.pending;
  double progress = 0;
  String? errorMessage;

  _UploadItem({
    required this.name,
    required this.path,
    required this.size,
  });
}

String _formatMaxSize(int maxFileSizeMb) {
  if (maxFileSizeMb >= 1024) {
    final gb = maxFileSizeMb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }
  return '$maxFileSizeMb MB';
}

String _formatFileSize(int bytes) {
  return DownloadUtils.formatFileSize(bytes);
}

Future<void> showCloudUploadSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int maxFileSizeMb,
  String? currentFolderId,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => _CloudUploadSheet(
      ref: ref,
      maxFileSizeMb: maxFileSizeMb,
      currentFolderId: currentFolderId,
    ),
  );
}

class _CloudUploadSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final int maxFileSizeMb;
  final String? currentFolderId;

  const _CloudUploadSheet({
    required this.ref,
    required this.maxFileSizeMb,
    this.currentFolderId,
  });

  @override
  _CloudUploadSheetState createState() => _CloudUploadSheetState();
}

class _CloudUploadSheetState extends ConsumerState<_CloudUploadSheet> {
  final List<_UploadItem> _items = [];
  bool _isUploading = false;

  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    setState(() {
      for (final file in result.files) {
        if (file.path != null && !_items.any((i) => i.path == file.path)) {
          _items.add(_UploadItem(
            name: file.name,
            path: file.path!,
            size: file.size,
          ));
        }
      }
    });
  }

  Future<void> _startUpload() async {
    if (_items.isEmpty || _isUploading) return;
    setState(() => _isUploading = true);

    final driveNotifier = widget.ref.read(misskeyDriveProvider.notifier);

    for (final item in _items) {
      if (item.status == _UploadStatus.completed) continue;
      setState(() {
        item.status = _UploadStatus.uploading;
        item.progress = 0;
      });

      try {
        final file = File(item.path);
        if (!file.existsSync()) {
          throw Exception('文件不存在: ${item.path}');
        }
        final bytes = await file.readAsBytes();
        item.progress = 0.5;

        await driveNotifier.uploadFile(bytes, item.name);

        if (!mounted) return;
        setState(() {
          item.status = _UploadStatus.completed;
          item.progress = 1.0;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          item.status = _UploadStatus.failed;
          item.errorMessage = e.toString();
        });
      }
    }

    if (!mounted) return;
    setState(() => _isUploading = false);
    if (_items.any((i) => i.status == _UploadStatus.completed)) {
      widget.ref.read(misskeyDriveProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: _items.isEmpty ? 0.4 : 0.65,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            _buildHandle(colorScheme),
            const SizedBox(height: 12),
            _buildHeader(colorScheme),
            const SizedBox(height: 16),
            Expanded(child: _buildFileList(scrollController, colorScheme)),
            const SizedBox(height: 16),
            _buildBottomButtons(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.cloud_upload_rounded, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '你可以上传最大 ${_formatMaxSize(widget.maxFileSizeMb)} 的文件。',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileList(ScrollController scrollController, ColorScheme colorScheme) {
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 48, color: colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text('cloud_upload_empty'.tr(), style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            _buildAddFileButton(colorScheme),
          ],
        ),
      );
    }

    return ListView(
      controller: scrollController,
      children: [
        ..._items.map((item) => _buildFileItem(item, colorScheme)),
        const SizedBox(height: 8),
        _buildAddFileButton(colorScheme),
        _buildFileCountInfo(colorScheme),
      ],
    );
  }

  Widget _buildFileItem(_UploadItem item, ColorScheme colorScheme) {
    final icon = _statusIcon(item.status);
    final iconColor = _statusColor(item.status, colorScheme);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.status == _UploadStatus.uploading
                          ? '上传中 ${(item.progress * 100).toInt()}%'
                          : item.status == _UploadStatus.failed
                              ? '上传失败: ${item.errorMessage ?? "未知错误"}'
                              : _formatFileSize(item.size),
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (item.status == _UploadStatus.uploading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: item.progress > 0 && item.progress < 1 ? null : item.progress,
                  ),
                ),
              if (item.status == _UploadStatus.failed && !_isUploading)
                IconButton(
                  icon: Icon(Icons.refresh_rounded, size: 18, color: colorScheme.error),
                  onPressed: () {
                    setState(() {
                      item.status = _UploadStatus.pending;
                      item.progress = 0;
                      item.errorMessage = null;
                    });
                  },
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              if (item.status == _UploadStatus.pending && !_isUploading)
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    setState(() => _items.remove(item));
                  },
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddFileButton(ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: _isUploading ? null : _pickFiles,
      icon: Icon(Icons.add_circle_outline_rounded, size: 18),
      label: Text('添加文件'),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildFileCountInfo(ColorScheme colorScheme) {
    final completed = _items.where((i) => i.status == _UploadStatus.completed).length;
    final failed = _items.where((i) => i.status == _UploadStatus.failed).length;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '共 ${_items.length} 个文件，$completed 成功${failed > 0 ? "，$failed 失败" : ""}',
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: Text('cloud_cancel'.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(color: colorScheme.outline),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: _isUploading || _items.isEmpty ? null : _startUpload,
            icon: Icon(
              _isUploading ? Icons.hourglass_top_rounded : Icons.cloud_upload_rounded,
              size: 18,
            ),
            label: Text(_isUploading ? '上传中...' : 'cloud_upload'.tr()),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  IconData _statusIcon(_UploadStatus status) {
    switch (status) {
      case _UploadStatus.pending:
        return Icons.insert_drive_file_outlined;
      case _UploadStatus.uploading:
        return Icons.cloud_upload_rounded;
      case _UploadStatus.completed:
        return Icons.check_circle_rounded;
      case _UploadStatus.failed:
        return Icons.error_outline_rounded;
    }
  }

  Color _statusColor(_UploadStatus status, ColorScheme colorScheme) {
    switch (status) {
      case _UploadStatus.pending:
        return colorScheme.onSurface;
      case _UploadStatus.uploading:
        return colorScheme.primary;
      case _UploadStatus.completed:
        return colorScheme.primary;
      case _UploadStatus.failed:
        return colorScheme.error;
    }
  }
}
