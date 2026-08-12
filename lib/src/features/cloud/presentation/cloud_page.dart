import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '/src/shared/widgets/toast_helper.dart';

import '/src/shared/widgets/adaptive_sheet.dart';
import '/src/core/utils/download_utils.dart';
import '/src/core/utils/file_icon_manager.dart';
import '/src/core/utils/cache_manager.dart';
import '/src/core/navigation/navigation.dart';
import '/src/features/misskey/application/drive_notifier.dart';
import '/src/features/misskey/application/file_upload_notifier.dart';
import '/src/features/misskey/domain/drive_file.dart';
import '/src/features/misskey/domain/drive_folder.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/shared/widgets/login_reminder.dart';
import '/src/shared/widgets/circle_icon_button.dart';
import '/src/shared/widgets/m3e_context_menu.dart';
import '/src/features/common/presentation/pages/media_viewer_page.dart';
import '/src/features/common/presentation/widgets/media/audio_player_sheet.dart';
import '/src/features/misskey/presentation/pages/misskey_post_page.dart';

import '/src/features/common/presentation/widgets/media/media_item.dart';
import 'cloud_upload_sheet.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';
import '/src/shared/widgets/cyani_error_widget.dart';

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

class _CloudPageState extends ConsumerState<CloudPage> with WidgetsBindingObserver {
  final Set<String> _selectedItems = {};
  final GlobalKey _listKey = GlobalKey();
  bool _isSelectionMode = false;
  bool _isButtonEnteredSelectionMode = false;
  bool _pendingRefreshOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pendingRefreshOnResume = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(selectedMisskeyAccountProvider).asData?.value;

    if (account == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => ref
                      .read(navigationControllerProvider.notifier)
                      .openDrawer(),
                ),
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

    if (_pendingRefreshOnResume) {
      _pendingRefreshOnResume = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(misskeyDriveProvider.notifier).refresh();
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: CircleIconButton(
          icon: Icons.menu,
          onPressed: () => ref
              .read(navigationControllerProvider.notifier)
              .openDrawer(),
        ),
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
                  CircleIconButton(
                    icon: Icons.download,
                    onPressed: () =>
                        _downloadSelectedFiles(context, ref, driveState.value!),
                    tooltip: 'cloud_download'.tr(),
                  ),
                CircleIconButton(
                  icon: Icons.delete,
                  onPressed: () => _batchDeleteSelected(context, ref, driveState.value ?? const DriveState()),
                  tooltip: 'cloud_delete'.tr(),
                ),
                CircleIconButton(
                  icon: Icons.close,
                  onPressed: _exitSelectionMode,
                  tooltip: 'cloud_cancel'.tr(),
                ),
              ],
            )
          else
            Row(
              children: [
                CircleIconButton(
                  icon: Icons.select_all,
                  onPressed: _enterSelectionMode,
                  tooltip: 'cloud_select'.tr(),
                ),
                CircleIconButton(
                  icon: Icons.refresh,
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
                child: _buildContentArea(context, ref, state),
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
              const Expanded(child: Center(child: CyaniLoadingIndicator())),
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
    await showAdaptiveSheet(
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
                                          ref
                                              .read(misskeyDriveProvider.notifier)
                                              .refresh();

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
            const Positioned(
              right: 0,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建内容区域，根据是否有文件/文件夹分别附加空区域右键菜单
  Widget _buildContentArea(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
  ) {
    if (state.files.isEmpty && state.folders.isEmpty && !state.isLoading) {
      return GestureDetector(
        onSecondaryTapDown: (details) {
          _showEmptyAreaContextMenu(context, ref, state, details.globalPosition);
        },
        child: _buildEmptyState(context),
      );
    }
    if (state.isLoading) {
      return const Center(child: CyaniLoadingIndicator());
    }
    return _buildContentList(context, ref, state);
  }

  Widget _buildContentList(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
  ) {
    final combined = [
      ...state.folders.map(_DriveItem.folder),
      ...state.files.map(_DriveItem.file),
    ];

    // CustomScrollView + SliverFillRemaining:
    // SliverFillRemaining 只在列表内容不足视口时才有正 extent，
    // 此时它会占据剩余空白区域并捕获右键。
    // 当内容填满/超出视口时，它的 extent = 0，不会与 item 产生
    // 手势冲突——因为它是 item GestureDetector 的平级节点，
    // 不在同一 hit-test 路径中，onSecondaryTapDown 不会同时触发。
    return CustomScrollView(
      key: _listKey,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = combined[index];
              final itemId = item.isFolder ? item.folder!.id : item.file!.id;
              final isSelected = _selectedItems.contains(itemId);

              return GestureDetector(
                onSecondaryTapDown: (details) {
                  // 右键->独占选择：只选中这一个，清除其他
                  setState(() {
                    _selectedItems.clear();
                    _selectedItems.add(itemId);
                    if (_isButtonEnteredSelectionMode) {
                      _isButtonEnteredSelectionMode = false;
                    }
                  });
                  _showFileContextMenu(context, ref, item, details.globalPosition);
                },
                child: ListTile(
              tileColor: isSelected
                  ? Theme.of(context).colorScheme.secondaryContainer.withAlpha(128)
                  : null,
              hoverColor: Theme.of(context).colorScheme.secondaryContainer.withAlpha(80),
              onTap: () {
                if (_isSelectionMode || _selectedItems.isNotEmpty) {
                  _toggleSelection(itemId);
                } else {
                  if (item.isFolder) {
                    ref.read(misskeyDriveProvider.notifier).cd(item.folder!);
                  } else {
                    _openFilePreview(context, item.file!);
                  }
                }
              },
              onLongPress: () {
                // 长按->独占选择 + 菜单
                setState(() {
                  _selectedItems.clear();
                  _selectedItems.add(itemId);
                  if (_isButtonEnteredSelectionMode) {
                    _isButtonEnteredSelectionMode = false;
                  }
                });
                _showFileContextMenu(context, ref, item, Offset.zero);
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
                _confirmDeleteSingle(context, ref, item);
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
        childCount: combined.length,
      ),
      ),
        // 仅在内容不足视口时占据剩余空白，捕获空白区域右键
        SliverFillRemaining(
          hasScrollBody: false,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onSecondaryTapDown: (details) {
              _showEmptyAreaContextMenu(
                context, ref, state, details.globalPosition,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEmptyAreaContextMenu(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
    Offset position,
  ) {
    M3EContextMenu.show<String>(
      context: context,
      position: position,
      items: [
        M3EMenuItemData(value: 'refresh', icon: Icons.refresh, label: 'cloud_refresh'.tr()),
        const M3EMenuItemData.separator(),
        M3EMenuItemData(value: 'upload', icon: Icons.upload_file, label: 'cloud_upload_file'.tr()),
        M3EMenuItemData(value: 'create_folder', icon: Icons.create_new_folder, label: 'cloud_create_folder'.tr()),
        const M3EMenuItemData.separator(),
        M3EMenuItemData(value: 'sort', icon: Icons.sort, label: 'cloud_sort_by'.tr()),
        M3EMenuItemData(value: 'open_in_browser', icon: Icons.open_in_browser, label: 'cloud_open_in_instance'.tr()),
      ],
      onSelected: (value) {
        if (!context.mounted) return;
        switch (value) {
          case 'refresh':
            ref.read(misskeyDriveProvider.notifier).refresh();
          case 'upload':
            _triggerUpload(context, ref, state);
          case 'create_folder':
            _showCreateFolderDialog(context, ref);
          case 'sort':
            _showSortMenu(context, ref, state, position);
          case 'open_in_browser':
            _openDriveInBrowser(context);
        }
      },
    );
  }

  void _showFileContextMenu(
    BuildContext context,
    WidgetRef ref,
    _DriveItem item,
    Offset position,
  ) {
    final isFolder = item.isFolder;
    final isSensitive = !isFolder && item.file!.isSensitive;
    final errorColor = Theme.of(context).colorScheme.error;

    M3EContextMenu.show<String>(
      context: context,
      position: position,
      items: [
        M3EMenuItemData(value: 'refresh', icon: Icons.refresh, label: 'cloud_refresh'.tr()),
        const M3EMenuItemData.separator(),
        M3EMenuItemData(
          value: 'open',
          icon: isFolder ? Icons.folder_open : Icons.open_in_new,
          label: 'cloud_open'.tr(),
        ),
        M3EMenuItemData(value: 'rename', icon: Icons.edit, label: 'cloud_rename'.tr()),
        if (!isFolder) ...[
          M3EMenuItemData(value: 'move', icon: Icons.drive_file_move, label: 'cloud_move_to'.tr()),
          M3EMenuItemData(value: 'download', icon: Icons.download, label: 'cloud_download'.tr()),
        ],
        const M3EMenuItemData.separator(),
        if (!isFolder) ...[
          M3EMenuItemData(value: 'post_with_file', icon: Icons.rate_review, label: 'cloud_post_with_file'.tr()),
          M3EMenuItemData(value: 'copy_link', icon: Icons.link, label: 'cloud_copy_link'.tr()),
          M3EMenuItemData(value: 'open_in_browser', icon: Icons.open_in_browser, label: 'cloud_open_in_browser'.tr()),
          const M3EMenuItemData.separator(),
          M3EMenuItemData(value: 'edit_description', icon: Icons.description, label: 'cloud_edit_description'.tr()),
          M3EMenuItemData(
            value: 'toggle_sensitive',
            icon: isSensitive ? Icons.visibility : Icons.visibility_off,
            label: isSensitive ? 'cloud_unmark_sensitive'.tr() : 'cloud_mark_sensitive'.tr(),
          ),
          M3EMenuItemData(value: 'copy_id', icon: Icons.tag, label: 'cloud_copy_id'.tr()),
        ],
        M3EMenuItemData(
          value: 'delete',
          icon: Icons.delete,
          label: 'cloud_delete'.tr(),
          iconColor: errorColor,
          textColor: errorColor,
        ),
      ],
      onSelected: (value) {
        if (!context.mounted) return;
        _handleFileContextAction(context, ref, item, value);
      },
    );
  }

  void _handleFileContextAction(
    BuildContext context,
    WidgetRef ref,
    _DriveItem item,
    String? value,
  ) {
    switch (value) {
      case 'refresh':
        ref.read(misskeyDriveProvider.notifier).refresh();
      case 'open':
        if (item.isFolder) {
          ref.read(misskeyDriveProvider.notifier).cd(item.folder!);
        } else {
          _openFilePreview(context, item.file!);
        }
      case 'rename':
        _showRenameDialog(context, ref, item);
      case 'move':
        if (!item.isFolder) {
          _showMoveDialog(context, ref, item.file!);
        }
      case 'download':
        if (!item.isFolder) {
          _downloadFile(context, item.file!);
        }
      case 'post_with_file':
        if (!item.isFolder) {
          _postWithFile(context, ref, item.file!);
        }
      case 'copy_link':
        if (!item.isFolder) {
          _copyLink(item.file!);
        }
      case 'open_in_browser':
        if (!item.isFolder) {
          _openUrl(item.file!.url);
        } else {
          _openDriveInBrowser(context);
        }
      case 'edit_description':
        if (!item.isFolder) {
          _showEditDescriptionDialog(context, ref, item.file!);
        }
      case 'toggle_sensitive':
        if (!item.isFolder) {
          _toggleSensitive(context, ref, item.file!);
        }
      case 'copy_id':
        if (!item.isFolder) {
          _copyFileId(item.file!);
        }
      case 'delete':
        _confirmDeleteSingle(context, ref, item);
    }
  }

  void _showSortMenu(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
    Offset position,
  ) {
    final currentMode = state.sortMode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    String sortLabel(DriveSortMode mode) {
      switch (mode) {
        case DriveSortMode.nameAsc: return 'cloud_sort_name_asc'.tr();
        case DriveSortMode.nameDesc: return 'cloud_sort_name_desc'.tr();
        case DriveSortMode.dateAsc: return 'cloud_sort_date_asc'.tr();
        case DriveSortMode.dateDesc: return 'cloud_sort_date_desc'.tr();
        case DriveSortMode.sizeAsc: return 'cloud_sort_size_asc'.tr();
        case DriveSortMode.sizeDesc: return 'cloud_sort_size_desc'.tr();
      }
    }

    IconData sortIcon(DriveSortMode mode) {
      switch (mode) {
        case DriveSortMode.nameAsc:
        case DriveSortMode.nameDesc: return Icons.sort_by_alpha;
        case DriveSortMode.dateAsc:
        case DriveSortMode.dateDesc: return Icons.calendar_today;
        case DriveSortMode.sizeAsc:
        case DriveSortMode.sizeDesc: return Icons.storage;
      }
    }

    M3EContextMenu.show<DriveSortMode>(
      context: context,
      position: position,
      items: DriveSortMode.values.map((mode) {
        final isSelected = mode == currentMode;
        return M3EMenuItemData(
          value: mode,
          icon: sortIcon(mode),
          label: sortLabel(mode),
          trailing: isSelected
              ? Icon(Icons.check, size: 18, color: primaryColor)
              : null,
        );
      }).toList(),
      onSelected: (value) {
        if (context.mounted) {
          ref.read(misskeyDriveProvider.notifier).setSortMode(value);
        }
      },
    );
  }

  void _triggerUpload(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
  ) {
    showCloudUploadSheet(
      context: context,
      ref: ref,
      maxFileSizeMb: state.maxFileSizeMb,
      currentFolderId: state.currentFolderId,
    );
  }

  void _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    _DriveItem item,
  ) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cloud_rename_title'.tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'cloud_enter_new_name'.tr()),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cloud_cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty && controller.text != item.name) {
                if (item.isFolder) {
                  ref
                      .read(misskeyDriveProvider.notifier)
                      .renameFolder(item.folder!.id, controller.text);
                } else {
                  ref
                      .read(misskeyDriveProvider.notifier)
                      .renameFile(item.file!.id, controller.text);
                }
              }
              Navigator.pop(context);
            },
            child: Text('cloud_rename'.tr()),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog(
    BuildContext context,
    WidgetRef ref,
    DriveFile file,
  ) async {
    final resultFolderName = await showDialog<String>(
      context: context,
      builder: (context) => const _FolderPickerDialog(),
    );
    if (resultFolderName == null || !context.mounted) return;

    // resultFolderName is 'root' or a folder ID
    final folderId = resultFolderName == 'root' ? null : resultFolderName;
    ref.read(misskeyDriveProvider.notifier).moveFile(file.id, folderId);
  }

  void _showEditDescriptionDialog(
    BuildContext context,
    WidgetRef ref,
    DriveFile file,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('cloud_edit_description'.tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'cloud_description_hint'.tr(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cloud_cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(misskeyDriveProvider.notifier)
                  .updateFileComment(file.id, controller.text);
              Navigator.pop(context);
            },
            child: Text('cloud_save'.tr()),
          ),
        ],
      ),
    );
  }

  void _toggleSensitive(
    BuildContext context,
    WidgetRef ref,
    DriveFile file,
  ) {
    ref
        .read(misskeyDriveProvider.notifier)
        .toggleFileSensitive(file.id, !file.isSensitive);
    if (context.mounted) {
      showToast(title: 'cloud_sensitive_updated'.tr(), type: ToastificationType.success);
    }
  }

  void _copyLink(DriveFile file) {
    Clipboard.setData(ClipboardData(text: file.url));
    // SnackBar is shown after context rebuild — use a global key or skip
  }

  void _copyFileId(DriveFile file) {
    Clipboard.setData(ClipboardData(text: file.id));
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openDriveInBrowser(BuildContext context) {
    final host = ref.watch(selectedMisskeyAccountProvider).value?.host;
    if (host == null) return;
    final driveUrl = 'https://$host/my/drive';
    _openUrl(driveUrl);
  }

  void _postWithFile(BuildContext context, WidgetRef ref, DriveFile file) {
    // 将文件添加到发帖页面的上传队列
    ref.read(fileUploadProvider.notifier).addExistingDriveFile(file);
    // 导航到发帖页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MisskeyPostPage()),
    );
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
            error: (_, _) => CyaniErrorWidget(
              message: 'cloud_error'.tr(),
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
    showAdaptiveSheet(
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
                final driveState = ref.read(misskeyDriveProvider).asData?.value;
                showCloudUploadSheet(
                  context: context,
                  ref: ref,
                  maxFileSizeMb: driveState?.maxFileSizeMb ?? 0,
                  currentFolderId: driveState?.currentFolderId,
                );
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

  Future<bool> _confirmDelete(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cloud_cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text('cloud_delete'.tr()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _confirmDeleteSingle(
    BuildContext context,
    WidgetRef ref,
    _DriveItem item,
  ) async {
    final name = item.name;
    final confirmed = await _confirmDelete(
      context,
      'cloud_delete'.tr(),
      'cloud_delete_confirm_single'.tr(namedArgs: {'name': name}),
    );
    if (!confirmed || !context.mounted) return;

    if (item.isFolder) {
      ref.read(misskeyDriveProvider.notifier).deleteFolder(item.folder!.id);
    } else {
      ref.read(misskeyDriveProvider.notifier).deleteFile(item.file!.id);
    }
  }

  void _batchDeleteSelected(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
  ) async {
    if (_selectedItems.isEmpty) return;

    final fileIds = state.files.where((f) => _selectedItems.contains(f.id)).map((f) => f.id).toList();
    final folderIds = state.folders.where((f) => _selectedItems.contains(f.id)).map((f) => f.id).toList();
    final total = fileIds.length + folderIds.length;

    final confirmed = await _confirmDelete(
      context,
      'cloud_delete'.tr(),
      'cloud_delete_confirm_batch'.tr(namedArgs: {'count': total.toString()}),
    );
    if (!confirmed || !context.mounted) return;

    _clearSelection();

    final notifier = ref.read(misskeyDriveProvider.notifier);
    for (final fid in folderIds) {
      notifier.deleteFolder(fid);
    }
    for (final fid in fileIds) {
      notifier.deleteFile(fid);
    }
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
      // 音频文件 - 打开M3E风格底部弹出播放器
      showAudioPlayerSheet(
        context,
        mediaItem: MediaItem(
          url: file.url,
          type: MediaType.audio,
          fileName: file.name,
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
    await showAdaptiveSheet(
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
                                            ref
                                                .read(misskeyDriveProvider.notifier)
                                                .refresh();

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

/// 文件夹选择器弹窗
///
/// 显示当前云盘的文件夹列表供用户选择移动目标。
class _FolderPickerDialog extends ConsumerStatefulWidget {
  const _FolderPickerDialog();

  @override
  ConsumerState<_FolderPickerDialog> createState() => _FolderPickerDialogState();
}

class _FolderPickerDialogState extends ConsumerState<_FolderPickerDialog> {
  String? _selectedFolderId;

  @override
  Widget build(BuildContext context) {
    final driveState = ref.watch(misskeyDriveProvider).asData?.value;
    final folders = driveState?.folders ?? [];

    return AlertDialog(
      title: Text('cloud_select_folder'.tr()),
      content: SizedBox(
        width: double.maxFinite,
        child: RadioGroup<String?>(
          groupValue: _selectedFolderId,
          onChanged: (v) => setState(() => _selectedFolderId = v),
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Radio<String?>(value: 'root'),
                title: Text('cloud_drive'.tr()),
                onTap: () => setState(() => _selectedFolderId = 'root'),
              ),
              ...folders.map((f) => ListTile(
                leading: Radio<String?>(value: f.id),
                title: Text(f.name),
                onTap: () => setState(() => _selectedFolderId = f.id),
              )),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cloud_cancel'.tr()),
        ),
        FilledButton(
          onPressed: _selectedFolderId != null
              ? () => Navigator.pop(context, _selectedFolderId)
              : null,
          child: Text('cloud_move'.tr()),
        ),
      ],
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
