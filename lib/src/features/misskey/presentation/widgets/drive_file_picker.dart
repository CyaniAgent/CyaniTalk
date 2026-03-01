import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/application/drive_notifier.dart';
import '/src/features/misskey/domain/drive_file.dart';
import '/src/features/misskey/domain/drive_folder.dart';

/// 云盘文件选择器 Bottom Sheet
///
/// 使用 Material Design 3 规范的可拖拽 Bottom Sheet 实现
class DriveFilePickerSheet extends ConsumerStatefulWidget {
  final int maxFiles;

  const DriveFilePickerSheet({super.key, this.maxFiles = 16});

  @override
  ConsumerState<DriveFilePickerSheet> createState() =>
      _DriveFilePickerSheetState();
}

class _DriveFilePickerSheetState extends ConsumerState<DriveFilePickerSheet> {
  final List<DriveFile> _selectedFiles = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(misskeyDriveProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // 拖动手柄
              _buildDragHandle(),
              // 内容区域
              Expanded(
                child: driveState.when(
                  data: (state) => _buildContent(state, scrollController),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorView(error.toString()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建拖动手柄
  Widget _buildDragHandle() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DriveState state, ScrollController scrollController) {
    return Column(
      children: [
        // 标题栏
        _buildHeader(),
        // 面包屑导航
        if (state.breadcrumbs.isNotEmpty) _buildBreadcrumbs(state),
        // 文件列表
        Expanded(child: _buildFileList(state, scrollController)),
        // 底部操作栏
        _buildBottomBar(),
      ],
    );
  }

  /// 构建标题栏
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder_open_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'drive_select_files'.tr(args: [widget.maxFiles.toString()]),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          // 关闭按钮
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'drive_cancel'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(DriveState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          // 根目录按钮
          IconButton(
            icon: Icon(Icons.folder_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'drive_root'.tr(),
            onPressed: () {
              ref.read(misskeyDriveProvider.notifier).cdBack();
            },
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          // 面包屑路径
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(state.breadcrumbs.length * 2 - 1, (
                  index,
                ) {
                  if (index.isEven) {
                    final folderIndex = index ~/ 2;
                    final folder = state.breadcrumbs[folderIndex];
                    return TextButton(
                      onPressed: () {
                        ref
                            .read(misskeyDriveProvider.notifier)
                            .cdTo(folderIndex);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        folder.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: folderIndex == state.breadcrumbs.length - 1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight:
                              folderIndex == state.breadcrumbs.length - 1
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  } else {
                    return Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    );
                  }
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(DriveState state, ScrollController scrollController) {
    final files = state.files;
    final folders = state.folders;

    if (files.isEmpty && folders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: folders.length + files.length,
      itemBuilder: (context, index) {
        if (index < folders.length) {
          return _buildFolderItem(folders[index]);
        } else {
          final fileIndex = index - folders.length;
          return _buildFileItem(files[fileIndex]);
        }
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'drive_empty_folder'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'drive_empty_folder_hint'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建文件夹项
  Widget _buildFolderItem(DriveFolder folder) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ref.read(misskeyDriveProvider.notifier).cd(folder);
          },
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // 前导图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // 文件夹信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        folder.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'drive_folder'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // 尾随图标
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建文件项
  Widget _buildFileItem(DriveFile file) {
    final isSelected = _selectedFiles.any((f) => f.id == file.id);
    final isMaxReached =
        _selectedFiles.length >= widget.maxFiles && !isSelected;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isMaxReached
              ? null
              : () {
                  setState(() {
                    if (isSelected) {
                      _selectedFiles.remove(file);
                    } else {
                      _selectedFiles.add(file);
                    }
                  });
                },
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // 前导图标
                _buildFileIcon(file),
                const SizedBox(width: 16),
                // 文件信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        file.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(file.size),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 缩略图（如果有）
                if (file.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.network(
                        file.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image_rounded,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (file.thumbnailUrl != null) const SizedBox(width: 12),
                // MD3 Checkbox
                _buildMD3Checkbox(isSelected, isMaxReached, file),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建文件类型图标
  Widget _buildFileIcon(DriveFile file) {
    IconData iconData;
    if (file.type.startsWith('image/')) {
      iconData = Icons.image_rounded;
    } else if (file.type.startsWith('video/')) {
      iconData = Icons.video_library_rounded;
    } else if (file.type.startsWith('audio/')) {
      iconData = Icons.music_note_rounded;
    } else if (file.type.contains('pdf')) {
      iconData = Icons.picture_as_pdf_rounded;
    } else if (file.type.contains('word') || file.type.contains('document')) {
      iconData = Icons.description_rounded;
    } else if (file.type.contains('excel') ||
        file.type.contains('spreadsheet')) {
      iconData = Icons.table_chart_rounded;
    } else if (file.type.contains('powerpoint') ||
        file.type.contains('presentation')) {
      iconData = Icons.slideshow_rounded;
    } else if (file.type.contains('zip') || file.type.contains('compressed')) {
      iconData = Icons.folder_zip_rounded;
    } else {
      iconData = Icons.insert_drive_file_rounded;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
    );
  }

  /// 构建 MD3 风格的 Checkbox
  Widget _buildMD3Checkbox(bool isSelected, bool isMaxReached, DriveFile file) {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary;
            }
            return Theme.of(context).colorScheme.onSurfaceVariant;
          }),
          checkColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.onPrimary;
            }
            return Theme.of(context).colorScheme.onSurface;
          }),
        ),
      ),
      child: Checkbox(
        value: isSelected,
        onChanged: isMaxReached
            ? null
            : (value) {
                setState(() {
                  if (value == true) {
                    _selectedFiles.add(file);
                  } else {
                    _selectedFiles.remove(file);
                  }
                });
              },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    final selectedCount = _selectedFiles.length;
    final maxFiles = widget.maxFiles;
    final isAtLimit = selectedCount >= maxFiles;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 选中数量提示
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getSelectedCountText(selectedCount, maxFiles, isAtLimit),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isAtLimit
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: isAtLimit ? FontWeight.w600 : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 取消按钮
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('drive_cancel'.tr()),
            ),
            const SizedBox(width: 8),
            // 确认按钮
            FilledButton.icon(
              onPressed: selectedCount == 0
                  ? null
                  : () {
                      Navigator.of(context).pop(_selectedFiles);
                    },
              icon: const Icon(Icons.check_rounded, size: 20),
              label: Text(
                'drive_confirm'.tr(args: [_selectedFilesLength.tr()]),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectedCountText(
    int selectedCount,
    int maxFiles,
    bool isAtLimit,
  ) {
    if (selectedCount == 0) {
      return 'drive_no_files_selected'.tr();
    } else if (selectedCount == 1) {
      return 'drive_one_file_selected'.tr();
    } else if (isAtLimit) {
      return 'drive_max_files_reached'.tr(args: [maxFiles.toString()]);
    } else {
      return 'drive_selected_count'.tr(
        args: [selectedCount.toString(), maxFiles.toString()],
      );
    }
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'drive_load_failed'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(misskeyDriveProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get _selectedFilesLength => _selectedFiles.length.toString();
}

/// 显示文件选择器 Bottom Sheet
///
/// 这是一个便捷方法，用于显示模态的文件选择器
Future<List<DriveFile>?> showDriveFilePicker({
  required BuildContext context,
  int maxFiles = 16,
}) {
  return showModalBottomSheet<List<DriveFile>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: (context) => DriveFilePickerSheet(maxFiles: maxFiles),
  );
}
