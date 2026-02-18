import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import '/src/core/navigation/navigation.dart';
import '/src/features/misskey/application/drive_notifier.dart';
import '/src/features/misskey/domain/drive_file.dart';
import '/src/features/misskey/domain/drive_folder.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/shared/widgets/login_reminder.dart';
import '/src/features/common/presentation/pages/media_viewer_page.dart';

import '/src/features/common/presentation/widgets/media/media_item.dart';

class CloudPage extends ConsumerWidget {
  const CloudPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(selectedMisskeyAccountProvider).asData?.value;

    if (account == null) {
      return Scaffold(
        appBar: AppBar(
          leading: Breakpoints.small.isActive(context)
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => ref
                      .read(navigationControllerProvider.notifier)
                      .openDrawer(),
                )
              : null,
          title: Text('cloud_storage_title'.tr()),
        ),
        body: LoginReminder(
          title: 'misskey_page_no_account_title'.tr(),
          message: 'misskey_page_please_login'.tr(),
          icon: Icons.cloud_off_outlined,
        ),
      );
    }

    final driveState = ref.watch(misskeyDriveProvider);
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Breakpoints.small.isActive(context)
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => ref
                    .read(navigationControllerProvider.notifier)
                    .openDrawer(),
              )
            : null,
        title: Text('cloud_storage_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: 'cloud_debug_show_raw_info'.tr(),
            onPressed: () => _showRawDebugInfo(context, ref, driveState.value),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(misskeyDriveProvider.notifier).refresh(),
          ),
        ],
      ),
      body: driveState.when(
        data: (state) => Column(
          children: [
            _buildBreadcrumbs(context, ref, state),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(misskeyDriveProvider.notifier).refresh(),
                child: state.files.isEmpty && state.folders.isEmpty
                    ? _buildEmptyState(context)
                    : _buildContentList(context, ref, state),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: _buildDriveSpace(context, driveState),
      floatingActionButton: FloatingActionButton(
        heroTag: 'cloud_fab',
        onPressed: () => _showAddOptions(context, ref),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBreadcrumbs(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.breadcrumbs.length + 1,
        separatorBuilder: (context, index) =>
            const Icon(Icons.chevron_right, size: 16),
        itemBuilder: (context, index) {
          final isLast = index == state.breadcrumbs.length;
          final title = index == 0
              ? 'cloud_drive'.tr()
              : state.breadcrumbs[index - 1].name;

          return TextButton(
            onPressed: isLast
                ? null
                : () => ref.read(misskeyDriveProvider.notifier).cdTo(index - 1),
            child: Text(
              title,
              style: TextStyle(
                color: isLast ? null : Theme.of(context).primaryColor,
                fontWeight: isLast ? FontWeight.bold : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentList(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
  ) {
    final combined = [
      ...state.folders.map((f) => _DriveItem.folder(f)),
      ...state.files.map((f) => _DriveItem.file(f)),
    ];

    return ListView.builder(
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];
        return ListTile(
          leading: item.isFolder
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                )
              : _buildFileIcon(item.file!),
          title: Text(item.name),
          subtitle: Text(item.subtitle),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showItemOptions(context, ref, item),
          ),
          onTap: () {
            if (item.isFolder) {
              ref.read(misskeyDriveProvider.notifier).cd(item.folder!);
            } else {
              _openFilePreview(context, item.file!);
            }
          },
        );
      },
    );
  }

  Widget _buildFileIcon(DriveFile file) {
    if (file.thumbnailUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          file.thumbnailUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.insert_drive_file),
        ),
      );
    }
    return const Icon(Icons.insert_drive_file);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'cloud_no_files_or_folders'.tr(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveSpace(
    BuildContext context,
    AsyncValue<DriveState> driveState,
  ) {
    final theme = Theme.of(context);

    return BottomAppBar(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'cloud_drive_space'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              driveState.when(
                data: (state) => Text(
                  '${_formatBytes(state.driveUsage.toDouble())} / ${_formatBytes(state.driveCapacityMb * 1024 * 1024.0)}',
                  style: theme.textTheme.bodySmall,
                ),
                loading: () => const SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    minHeight: 16,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                error: (_, _) => Text(
                  'cloud_error'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          driveState.when(
            data: (state) {
              if (state.driveCapacityMb == 0) {
                return const SizedBox.shrink();
              }
              final usedBytes = state.driveUsage.toDouble();
              final totalBytes = state.driveCapacityMb * 1024 * 1024.0;
              final percent = (usedBytes / totalBytes).clamp(0.0, 1.0);
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent > 0.9
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
              );
            },
            loading: () => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            error: (_, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder),
              title: Text('cloud_create_folder'.tr()),
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text('cloud_upload_file'.tr()),
              onTap: () {
                Navigator.pop(context);
                // Implementation for picking and uploading file
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cloud_new_folder'.tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'cloud_folder_name'.tr()),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cloud_cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(misskeyDriveProvider.notifier)
                    .createFolder(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text('cloud_create'.tr()),
          ),
        ],
      ),
    );
  }

  void _showItemOptions(BuildContext context, WidgetRef ref, _DriveItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'cloud_delete'.tr(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                if (item.isFolder) {
                  ref
                      .read(misskeyDriveProvider.notifier)
                      .deleteFolder(item.folder!.id);
                } else {
                  ref
                      .read(misskeyDriveProvider.notifier)
                      .deleteFile(item.file!.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openFilePreview(BuildContext context, DriveFile file) {
    final mimeType = file.type.toLowerCase();

    if (mimeType.startsWith('image/')) {
      // 图片文件 - 打开媒体查看器
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaViewerPage(
            mediaItems: [
              MediaItem(
                url: file.url,
                type: MediaType.image,
                fileName: file.name,
              ),
            ],
            heroTag: 'cloud_image_${file.id}',
          ),
        ),
      );
    } else if (mimeType.startsWith('video/')) {
      // 视频文件 - 打开媒体查看器
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaViewerPage(
            mediaItems: [
              MediaItem(
                url: file.url,
                type: MediaType.video,
                fileName: file.name,
              ),
            ],
          ),
        ),
      );
    } else if (mimeType.startsWith('audio/')) {
      // 音频文件 - 打开媒体查看器
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MediaViewerPage(
            mediaItems: [
              MediaItem(
                url: file.url,
                type: MediaType.audio,
                fileName: file.name,
              ),
            ],
          ),
        ),
      );
    } else {
      // 其他文件类型 - 显示文件信息
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(file.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('类型: ${file.type}'),
              Text('大小: ${_formatBytes(file.size.toDouble())}'),
              Text('创建时间: ${DateFormat.yMd().add_Hm().format(file.createdAt)}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: 实现文件下载
                },
                child: const Text('下载文件'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cloud_close'.tr()),
            ),
          ],
        ),
      );
    }
  }

  void _showRawDebugInfo(
    BuildContext context,
    WidgetRef ref,
    DriveState? state,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cloud_debug_raw_data'.tr()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('driveCapacityMb: ${state?.driveCapacityMb} MB'),
              Text('driveUsage: ${state?.driveUsage} bytes'),
              const Divider(),
              Text(
                'cloud_debug_check_console'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cloud_close'.tr()),
          ),
        ],
      ),
    );
  }
}

class _DriveItem {
  final DriveFile? file;
  final DriveFolder? folder;

  _DriveItem.file(this.file) : folder = null;
  _DriveItem.folder(this.folder) : file = null;

  bool get isFolder => folder != null;
  String get name => isFolder ? folder!.name : file!.name;
  String get subtitle {
    if (isFolder) {
      return '${'cloud_folder'.tr()} • ${DateFormat.yMd().format(folder!.createdAt)}';
    }
    final sizeStr = _formatBytes(file!.size.toDouble());
    return '$sizeStr • ${DateFormat.yMd().format(file!.createdAt)}';
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
