import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/application/drive_notifier.dart';
import '/src/features/misskey/domain/drive_file.dart';
import '/src/features/misskey/domain/drive_folder.dart';
import '/src/features/misskey/presentation/widgets/attachment_card.dart';

/// 云盘文件选择器组件
///
/// 用于从 Misskey 云盘选择文件，支持文件夹导航和文件搜索
class DriveFilePicker extends ConsumerStatefulWidget {
  final Function(List<DriveFile>) onFilesSelected;
  final int maxFiles;

  const DriveFilePicker({
    super.key,
    required this.onFilesSelected,
    this.maxFiles = 10,
  });

  @override
  ConsumerState<DriveFilePicker> createState() => _DriveFilePickerState();
}

class _DriveFilePickerState extends ConsumerState<DriveFilePicker> {
  final List<DriveFile> _selectedFiles = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(misskeyDriveProvider);

    return driveState.when(
      data: (state) => _buildContent(state),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorView(error.toString()),
    );
  }

  Widget _buildContent(DriveState state) {
    return Column(
      children: [
        // 搜索栏
        _buildSearchBar(state),
        
        // 面包屑导航
        if (state.breadcrumbs.isNotEmpty)
          _buildBreadcrumbs(state),
        
        // 文件列表
        Expanded(
          child: _buildFileList(state),
        ),
        
        // 底部操作栏
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildSearchBar(DriveState state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'drive_search_files'.tr(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(misskeyDriveProvider.notifier)
                            .refresh();
                      },
                    )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          // TODO: 实现搜索功能
          setState(() {
            _isSearching = value.isNotEmpty;
          });
        },
        onSubmitted: (value) {
          // TODO: 执行搜索
          if (value.isNotEmpty) {
            // 调用搜索 API
          }
        },
      ),
    );
  }

  Widget _buildBreadcrumbs(DriveState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // 根目录
          IconButton(
            icon: const Icon(Icons.folder, size: 20),
            tooltip: 'drive_root'.tr(),
            onPressed: () {
              ref.read(misskeyDriveProvider.notifier)
                  .cdBack(); // 返回到根目录（多次调用或重构）
            },
          ),
          const Icon(Icons.chevron_right, size: 16),
          
          // 面包屑路径
          ...state.breadcrumbs.asMap().entries.expand((entry) {
            final index = entry.key;
            final folder = entry.value;
            return [
              TextButton(
                onPressed: () {
                  // 导航到指定文件夹（需要实现 cdTo 方法）
                  ref.read(misskeyDriveProvider.notifier)
                      .cdTo(index);
                },
                child: Text(
                  folder.name,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (index < state.breadcrumbs.length - 1)
                const Icon(Icons.chevron_right, size: 16),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildFileList(DriveState state) {
    final files = state.files;
    final folders = state.folders;

    if (files.isEmpty && folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'drive_empty_folder'.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: folders.length + files.length,
      itemBuilder: (context, index) {
        if (index < folders.length) {
          // 显示文件夹
          return _buildFolderItem(folders[index]);
        } else {
          // 显示文件
          final fileIndex = index - folders.length;
          return _buildFileItem(files[fileIndex]);
        }
      },
    );
  }

  Widget _buildFolderItem(DriveFolder folder) {
    return ListTile(
      leading: const Icon(Icons.folder, size: 32),
      title: Text(folder.name),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.outline,
      ),
      onTap: () {
        ref.read(misskeyDriveProvider.notifier)
            .cd(folder);
      },
    );
  }

  Widget _buildFileItem(DriveFile file) {
    final isSelected = _selectedFiles.any((f) => f.id == file.id);
    final isMaxReached = _selectedFiles.length >= widget.maxFiles && !isSelected;

    return ListTile(
      leading: FileTypeIcon(
        fileType: file.type,
        size: 32,
      ),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatFileSize(file.size),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (file.thumbnailUrl != null)
            SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  file.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image, size: 20),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(width: 8),
          Checkbox(
            value: isSelected,
            onChanged: isMaxReached ? null : (value) {
              setState(() {
                if (value == true) {
                  _selectedFiles.add(file);
                } else {
                  _selectedFiles.remove(file);
                }
              });
            },
          ),
        ],
      ),
      onTap: () {
        if (isMaxReached) return;
        
        setState(() {
          if (isSelected) {
            _selectedFiles.remove(file);
          } else {
            _selectedFiles.add(file);
          }
        });
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'drive_selected_count'.tr(args: [
              _selectedFiles.length.toString(),
              widget.maxFiles.toString(),
            ]),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('cancel'.tr()),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _selectedFiles.isEmpty
                ? null
                : () {
                    widget.onFilesSelected(_selectedFiles);
                    Navigator.of(context).pop();
                  },
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'drive_load_failed'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(misskeyDriveProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
