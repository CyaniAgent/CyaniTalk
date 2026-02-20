import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
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
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'download' && !item.isFolder) {
                _downloadFile(context, item.file!);
              } else if (value == 'delete') {
                if (item.isFolder) {
                  ref
                      .read(misskeyDriveProvider.notifier)
                      .deleteFolder(item.folder!.id);
                } else {
                  ref
                      .read(misskeyDriveProvider.notifier)
                      .deleteFile(item.file!.id);
                }
              }
            },
            itemBuilder: (context) => [
              if (!item.isFolder)
                PopupMenuItem(
                  value: 'download',
                  child: ListTile(
                    leading: const Icon(Icons.download),
                    title: Text('cloud_download'.tr()),
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'cloud_delete'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
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
                  _downloadFile(context, file);
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

  Future<void> _downloadFile(BuildContext context, DriveFile file) async {
    final dio = Dio();
    double progress = 0.0;
    String status = '准备下载';
    String savePath = '';

    // 显示下载确认底页
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'cloud_download_confirm'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('cloud_file_name'.tr(namedArgs: {'name': file.name})),

                    const SizedBox(height: 8),
                    Text(
                      'cloud_file_size'.tr(
                        namedArgs: {'size': _formatBytes(file.size.toDouble())},
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text('cloud_download_link'.tr()),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        file.url,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'Monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (savePath.isNotEmpty) ...[
                      Text(
                        'cloud_save_location'.tr(namedArgs: {'path': savePath}),
                      ),

                      const SizedBox(height: 8),
                    ],
                    if (progress > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        'cloud_download_progress'.tr(
                          namedArgs: {
                            'progress':
                                '${(progress * 100).toStringAsFixed(1)}%',
                          },
                        ),
                      ),

                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(status),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('cloud_cancel'.tr()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: progress > 0
                                ? null
                                : () async {
                                    // 获取下载目录
                                    final directory =
                                        await getDownloadsDirectory();
                                    if (directory == null) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'cloud_no_download_directory'
                                                  .tr(),
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    // 构建文件保存路径
                                    savePath = '${directory.path}/${file.name}';
                                    setState(() {});

                                    try {
                                      // 开始下载
                                      setState(() {
                                        status = '开始下载...';
                                      });

                                      await dio.download(
                                        file.url,
                                        savePath,
                                        onReceiveProgress: (received, total) {
                                          if (total != -1) {
                                            setState(() {
                                              progress = received / total;
                                              status =
                                                  '下载中... ${(progress * 100).toStringAsFixed(1)}%';
                                            });
                                          }
                                        },
                                      );

                                      setState(() {
                                        status = '下载完成';
                                      });

                                      // 显示完成信息
                                      if (context.mounted) {
                                        final currentContext = context;
                                        await showDialog(
                                          context: currentContext,
                                          builder: (dialogContext) =>
                                              AlertDialog(
                                                title: Text(
                                                  'cloud_download_completed'
                                                      .tr(),
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'cloud_file_saved_to'.tr(
                                                        namedArgs: {
                                                          'path': savePath,
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                        dialogContext,
                                                      );
                                                      if (currentContext
                                                          .mounted) {
                                                        Navigator.pop(
                                                          currentContext,
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      'cloud_close'.tr(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        status = '下载失败';
                                      });

                                      if (context.mounted) {
                                        final currentContext = context;
                                        await showDialog(
                                          context: currentContext,
                                          builder: (dialogContext) =>
                                              AlertDialog(
                                                title: Text(
                                                  'cloud_download_failed'.tr(),
                                                ),
                                                content: Text(
                                                  'cloud_error_message'.tr(
                                                    namedArgs: {
                                                      'message': e.toString(),
                                                    },
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                        dialogContext,
                                                      );
                                                      if (currentContext
                                                          .mounted) {
                                                        Navigator.pop(
                                                          currentContext,
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      'cloud_close'.tr(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      }
                                    }
                                  },
                            child: progress > 0
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('cloud_start_download'.tr()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
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
