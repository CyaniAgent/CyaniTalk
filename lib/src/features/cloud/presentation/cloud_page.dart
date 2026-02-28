import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import '/src/core/utils/download_utils.dart';
import '/src/core/utils/file_icon_manager.dart';
import '/src/core/utils/cache_manager.dart';
import '/src/core/navigation/navigation.dart';
import '/src/features/misskey/application/drive_notifier.dart';
import '/src/features/misskey/domain/drive_file.dart';
import '/src/features/misskey/domain/drive_folder.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/shared/widgets/login_reminder.dart';
import '/src/features/common/presentation/pages/media_viewer_page.dart';

import '/src/features/common/presentation/widgets/media/media_item.dart';

class CloudPage extends ConsumerStatefulWidget {
  const CloudPage({super.key});

  @override
  ConsumerState<CloudPage> createState() => _CloudPageState();
}

/// 缓存缩略图小部件
class _CachedThumbnail extends StatefulWidget {
  final String thumbnailUrl;
  final IconData icon;

  const _CachedThumbnail({
    required this.thumbnailUrl,
    required this.icon,
  });

  @override
  State<_CachedThumbnail> createState() => _CachedThumbnailState();
}

class _CachedThumbnailState extends State<_CachedThumbnail> {
  Future<String?> _cacheThumbnail() async {
    try {
      // 检查是否已缓存
      final isCached = await cacheManager.isFileCachedAndValid(
        widget.thumbnailUrl,
        CacheCategory.image,
      );

      if (isCached) {
        // 已缓存，返回缓存路径
        return await cacheManager.getCacheFilePath(
          widget.thumbnailUrl,
          CacheCategory.image,
        );
      } else {
        // 未缓存，下载并缓存
        return await cacheManager.cacheFile(
          widget.thumbnailUrl,
          CacheCategory.image,
        );
      }
    } catch (e) {
      // 缓存失败，返回null
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _cacheThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 加载中，显示图标
          return Icon(widget.icon, size: 24);
        } else if (snapshot.hasData && snapshot.data != null) {
          // 缓存成功，显示本地缓存的图片
          return Image.file(
            File(snapshot.data!),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // 加载失败时显示图标
              return Icon(widget.icon, size: 24);
            },
          );
        } else {
          // 缓存失败，显示图标
          return Icon(widget.icon, size: 24);
        }
      },
    );
  }
}

class _CloudPageState extends ConsumerState<CloudPage> {
  final Set<String> _selectedItems = {};
  final GlobalKey _listKey = GlobalKey();
  bool _isSelectionMode = false;
  bool _isButtonEnteredSelectionMode = false;

  @override
  Widget build(BuildContext context) {
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
        title: (_isSelectionMode || _selectedItems.isNotEmpty)
            ? Text(
                'cloud_selected_items'.tr(
                  namedArgs: {'count': _selectedItems.length.toString()},
                ),
              )
            : Text('cloud_storage_title'.tr()),
        actions: [
          if (_isSelectionMode || _selectedItems.isNotEmpty)
            Row(
              children: [
                if (_selectedItems.any((id) {
                  final index =
                      driveState.value?.files.indexWhere((f) => f.id == id) ??
                      -1;
                  return index != -1;
                }))
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () =>
                        _downloadSelectedFiles(context, ref, driveState.value!),
                    tooltip: 'cloud_download'.tr(),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('功能开发中，敬请期待'), behavior: SnackBarBehavior.floating));
                  },
                  tooltip: 'cloud_delete'.tr(),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _exitSelectionMode(),
                  tooltip: 'cloud_cancel'.tr(),
                ),
              ],
            )
          else
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () => _enterSelectionMode(),
                  tooltip: 'cloud_select'.tr(),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      ref.read(misskeyDriveProvider.notifier).refresh(),
                  tooltip: 'cloud_refresh'.tr(),
                ),
              ],
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
                child:
                    state.files.isEmpty &&
                        state.folders.isEmpty &&
                        !state.isLoading
                    ? _buildEmptyState(context)
                    : state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContentList(context, ref, state),
              ),
            ),
          ],
        ),
        loading: () {
          // 使用最近的数据状态来显示面包屑导航
          final currentState = driveState.value ?? const DriveState();
          return Column(
            children: [
              _buildBreadcrumbs(context, ref, currentState),
              Expanded(child: const Center(child: CircularProgressIndicator())),
            ],
          );
        },
        error: (err, stack) {
          // 使用最近的数据状态来显示面包屑导航
          final currentState = driveState.value ?? const DriveState();
          return Column(
            children: [
              _buildBreadcrumbs(context, ref, currentState),
              Expanded(child: Center(child: Text('Error: $err'))),
            ],
          );
        },
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

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _isButtonEnteredSelectionMode = true;
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
        // 如果选择数量为0且不是通过按钮进入的选择模式，则退出选择模式
        if (_selectedItems.isEmpty && !_isButtonEnteredSelectionMode) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add(id);
        // 如果是通过按钮进入的选择模式，且已经选择了项目，则重置标志
        if (_isButtonEnteredSelectionMode) {
          _isButtonEnteredSelectionMode = false;
        }
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
      // 如果不是通过按钮进入的选择模式，则退出选择模式
      if (!_isButtonEnteredSelectionMode) {
        _isSelectionMode = false;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
      _isButtonEnteredSelectionMode = false;
    });
  }

  void _downloadSelectedFiles(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
  ) {
    final selectedFiles = state.files
        .where((f) => _selectedItems.contains(f.id))
        .toList();
    if (selectedFiles.isEmpty) return;

    if (selectedFiles.length == 1) {
      // 单个文件下载，使用原有的下载方法
      _downloadFile(context, selectedFiles[0]);
    } else {
      // 多个文件下载，使用新的多文件下载方法
      _downloadMultipleFiles(context, selectedFiles);
    }
    _clearSelection(); // 只清空选中项，不退出选择模式
  }

  Future<void> _downloadMultipleFiles(
    BuildContext context,
    List<DriveFile> files,
  ) async {
    int completedCount = 0;
    int totalCount = files.length;
    String currentFile = '';
    double overallProgress = 0.0;
    double currentFileProgress = 0.0;
    String status = 'cloud_download_preparing'.tr();
    String downloadPath = '';
    bool isDownloading = false;
    bool isDownloadComplete = false;

    // 显示下载进度底页
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 40,
                          height: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isDownloading
                            ? 'cloud_downloading'.tr()
                            : isDownloadComplete
                            ? 'cloud_download_completed'.tr()
                            : 'cloud_download_preparing'.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!isDownloading && !isDownloadComplete) ...[
                        ExpansionTile(
                          initiallyExpanded: false,
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            '${files.length} ${'cloud_files_count'.tr()}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: files.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                                itemBuilder: (context, index) {
                                  final file = files[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SelectableText(
                                          file.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        SelectableText(
                                          file.url,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Text(
                          'cloud_downloading_files'.tr(
                            namedArgs: {
                              'count': totalCount.toString(),
                              'completed': completedCount.toString(),
                            },
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        if (currentFile.isNotEmpty) ...[
                          SelectableText(
                            '${'cloud_current_file'.tr(namedArgs: {'name': ''})} ${completedCount + 1}/$totalCount: $currentFile',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          if (isDownloading)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: currentFileProgress > 0
                                      ? currentFileProgress
                                      : null,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(currentFileProgress * 100).toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                        ],
                        if (totalCount > 0) ...[
                          Text(
                            '${(overallProgress * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: isDownloading || isDownloadComplete
                                ? overallProgress
                                : null,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (downloadPath.isNotEmpty) ...[
                          Text(
                            'cloud_save_location'.tr(
                              namedArgs: {'path': downloadPath},
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          status,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: !isDownloading || isDownloadComplete
                                  ? () => Navigator.pop(context)
                                  : null,
                              child: Text('cloud_cancel'.tr()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: !isDownloading && !isDownloadComplete
                                  ? () async {
                                      setState(() {
                                        isDownloading = true;
                                        status = 'cloud_download_starting'.tr();
                                        if (files.isNotEmpty) {
                                          currentFile = files[0].name;
                                        }
                                      });
                                      try {
                                        // 创建下载配置列表
                                        final configs = files
                                            .map(
                                              (file) => DownloadConfig(
                                                url: file.url,
                                                fileName: file.name,
                                                maxRetries: 3,
                                                timeout: 60,
                                              ),
                                            )
                                            .toList();

                                        // 执行批量下载
                                        final results =
                                            await DownloadUtils.downloadFiles(
                                              configs: configs,
                                              onProgress:
                                                  (
                                                    received,
                                                    total,
                                                    progressValue,
                                                  ) {
                                                    setState(() {
                                                      currentFileProgress =
                                                          progressValue;
                                                      // 计算整体进度
                                                      if (totalCount > 0) {
                                                        overallProgress =
                                                            (completedCount +
                                                                progressValue) /
                                                            totalCount;
                                                      }
                                                    });
                                                  },
                                              onStatusChange:
                                                  (downloadStatus, message) {
                                                    if (message != null) {
                                                      setState(() {
                                                        status = message;
                                                      });
                                                    }
                                                  },
                                              onBatchProgress: (completed, total) {
                                                setState(() {
                                                  completedCount = completed;
                                                  if (total > 0) {
                                                    overallProgress =
                                                        completed / total;
                                                  }
                                                  if (completed < total) {
                                                    currentFile =
                                                        files[completed].name;
                                                  }
                                                  status =
                                                      'cloud_downloading_files'
                                                          .tr(
                                                            namedArgs: {
                                                              'count': total
                                                                  .toString(),
                                                              'completed':
                                                                  completed
                                                                      .toString(),
                                                            },
                                                          );
                                                });
                                              },
                                            );

                                        // 获取第一个成功下载的文件路径作为下载目录示例
                                        final successResult = results
                                            .firstWhere(
                                              (result) =>
                                                  result.status ==
                                                      DownloadStatus
                                                          .completed &&
                                                  result.filePath != null,
                                              orElse: () =>
                                                  const DownloadResult(
                                                    status:
                                                        DownloadStatus.failed,
                                                  ),
                                            );

                                        if (successResult.filePath != null) {
                                          final file = File(
                                            successResult.filePath!,
                                          );
                                          downloadPath = file.parent.path;
                                        }

                                        // 检查是否所有文件都下载成功
                                        final allSuccess = results.every(
                                          (result) =>
                                              result.status ==
                                              DownloadStatus.completed,
                                        );

                                        if (allSuccess &&
                                            downloadPath.isNotEmpty) {
                                          setState(() {
                                            isDownloadComplete = true;
                                            isDownloading = false;
                                            status = 'cloud_download_completed'
                                                .tr();
                                            overallProgress = 1.0;
                                            currentFileProgress = 1.0;
                                          });

                                          // 显示完成信息
                                          if (context.mounted) {
                                            await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                  'cloud_download_completed'
                                                      .tr(),
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'cloud_all_files_saved'.tr(
                                                        namedArgs: {
                                                          'count': totalCount
                                                              .toString(),
                                                          'path': downloadPath,
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                      'cloud_close'.tr(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        } else {
                                          // 计算失败的文件数
                                          final failedCount = results
                                              .where(
                                                (result) =>
                                                    result.status ==
                                                    DownloadStatus.failed,
                                              )
                                              .length;
                                          setState(() {
                                            isDownloadComplete = true;
                                            isDownloading = false;
                                            status =
                                                'cloud_download_failed_count'
                                                    .tr(
                                                      namedArgs: {
                                                        'failed': failedCount
                                                            .toString(),
                                                      },
                                                    );
                                          });
                                        }
                                      } catch (e) {
                                        // 显示错误信息
                                        setState(() {
                                          isDownloading = false;
                                          status = 'download_failed'.tr(
                                            namedArgs: {
                                              'message': e.toString(),
                                            },
                                          );
                                        });
                                      }
                                    }
                                  : null,
                              child: isDownloading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      !isDownloadComplete
                                          ? 'cloud_start_download'.tr()
                                          : 'cloud_download_completed'.tr(),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          ListView.separated(
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
                    : () => ref
                          .read(misskeyDriveProvider.notifier)
                          .cdTo(index - 1),
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
          if (state.isLoading)
            Positioned(
              right: 0,
              child: SizedBox(
                width: 24,
                height: 24,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
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
      key: _listKey,
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];
        final isSelected = _selectedItems.contains(
          item.isFolder ? item.folder!.id : item.file!.id,
        );

        return GestureDetector(
          onSecondaryTapDown: (details) {
            // 右键点击显示菜单
            _showContextMenu(context, ref, item, details.globalPosition);
          },
          child: ListTile(
            tileColor: isSelected
                ? Theme.of(context).colorScheme.secondaryContainer.withAlpha(128)
                : null,
            hoverColor: Theme.of(context).colorScheme.secondaryContainer.withAlpha(80),
            onTap: () {
              if (_isSelectionMode || _selectedItems.isNotEmpty) {
                // 如果处于选择模式或已经有选中的项目，则切换当前项目的选中状态
                _toggleSelection(item.isFolder ? item.folder!.id : item.file!.id);
              } else {
                // 否则执行正常的点击操作
                if (item.isFolder) {
                  ref.read(misskeyDriveProvider.notifier).cd(item.folder!);
                } else {
                  _openFilePreview(context, item.file!);
                }
              }
            },
            onLongPress: () {
              // 长按切换选中状态
              _toggleSelection(item.isFolder ? item.folder!.id : item.file!.id);
            },
            leading: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                Center(
                  child: item.isFolder
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.folder,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        )
                      : _buildFileIcon(item.file!),
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
          ),
        );
      },
    );
  }

  void _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    _DriveItem item,
    Offset position,
  ) {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final currentContext = context;
    showMenu<String>(
      context: currentContext,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
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
              color: Theme.of(currentContext).colorScheme.error,
            ),
            title: Text(
              'cloud_delete'.tr(),
              style: TextStyle(
                color: Theme.of(currentContext).colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'download' && !item.isFolder) {
        if (currentContext.mounted) {
          _downloadFile(currentContext, item.file!);
        }
      } else if (value == 'delete') {
        if (currentContext.mounted) {
          ScaffoldMessenger.of(
            currentContext,
          ).showSnackBar(SnackBar(content: Text('功能开发中，敬请期待'), behavior: SnackBarBehavior.floating));
        }
      }
    });
  }

  Widget _buildFileIcon(DriveFile file) {
    final icon = FileIconManager.getIconForFileName(file.name);
    if (file.thumbnailUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _CachedThumbnail(
          thumbnailUrl: file.thumbnailUrl!,
          icon: icon,
        ),
      );
    }
    return Icon(icon);
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
    return DownloadUtils.formatFileSize(bytes.toInt());
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

  Future<void> _downloadFile(BuildContext context, DriveFile file) async {
    double progress = 0.0;
    String status = 'cloud_download_preparing'.tr();
    String savePath = '';
    bool isDownloading = false;
    bool isDownloadComplete = false;

    // 显示下载确认底页
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
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
                      Text(
                        'cloud_file_name'.tr(namedArgs: {'name': file.name}),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'cloud_file_size'.tr(
                          namedArgs: {
                            'size': DownloadUtils.formatFileSize(file.size),
                          },
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'cloud_download_link'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          file.url,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'Monospace'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (savePath.isNotEmpty) ...[
                        Text(
                          'cloud_save_location'.tr(
                            namedArgs: {'path': savePath},
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (isDownloading || isDownloadComplete) ...[
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress > 0 ? progress : null,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          status,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 24),
                      ] else
                        const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: !isDownloading || isDownloadComplete
                                  ? () => Navigator.pop(context)
                                  : null,
                              child: Text('cloud_cancel'.tr()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: !isDownloading && !isDownloadComplete
                                  ? () async {
                                      setState(() {
                                        isDownloading = true;
                                        status = 'cloud_download_starting'.tr();
                                      });
                                      try {
                                        // 创建下载配置
                                        final config = DownloadConfig(
                                          url: file.url,
                                          fileName: file.name,
                                          maxRetries: 3,
                                          timeout: 60,
                                        );

                                        // 执行下载
                                        final result = await DownloadUtils.downloadFile(
                                          config: config,
                                          onProgress:
                                              (received, total, progressValue) {
                                                setState(() {
                                                  progress = progressValue;
                                                  status =
                                                      'cloud_downloading_current'.tr(
                                                        namedArgs: {
                                                          'progress':
                                                              (progress * 100)
                                                                  .toStringAsFixed(
                                                                    1,
                                                                  ),
                                                        },
                                                      );
                                                });
                                              },
                                          onStatusChange:
                                              (downloadStatus, message) {
                                                if (message != null) {
                                                  setState(() {
                                                    status = message;
                                                  });
                                                }
                                              },
                                        );

                                        if (result.status ==
                                                DownloadStatus.completed &&
                                            result.filePath != null) {
                                          savePath = result.filePath!;
                                          setState(() {
                                            isDownloadComplete = true;
                                            isDownloading = false;
                                            status = 'cloud_download_completed'
                                                .tr();
                                            progress = 1.0;
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
                                                          'cloud_file_saved_to'
                                                              .tr(
                                                                namedArgs: {
                                                                  'path':
                                                                      savePath,
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
                                        } else {
                                          setState(() {
                                            isDownloadComplete = false;
                                            isDownloading = false;
                                            status = 'cloud_download_failed'
                                                .tr();
                                          });

                                          if (context.mounted) {
                                            final currentContext = context;
                                            await showDialog(
                                              context: currentContext,
                                              builder: (dialogContext) =>
                                                  AlertDialog(
                                                    title: Text(
                                                      'cloud_download_failed'
                                                          .tr(),
                                                    ),
                                                    content: Text(
                                                      'cloud_error_message'.tr(
                                                        namedArgs: {
                                                          'message':
                                                              result
                                                                  .errorMessage ??
                                                              'error_unknown'
                                                                  .tr(),
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
                                      } catch (e) {
                                        setState(() {
                                          isDownloading = false;
                                          status = 'download_failed'.tr(
                                            namedArgs: {
                                              'message': e.toString(),
                                            },
                                          );
                                        });

                                        if (context.mounted) {
                                          final currentContext = context;
                                          await showDialog(
                                            context: currentContext,
                                            builder: (dialogContext) =>
                                                AlertDialog(
                                                  title: Text(
                                                    'cloud_download_failed'
                                                        .tr(),
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
                                    }
                                  : null,
                              child: isDownloading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      !isDownloadComplete
                                          ? 'cloud_start_download'.tr()
                                          : 'cloud_download_completed'.tr(),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
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
    return DownloadUtils.formatFileSize(bytes.toInt());
  }
}
