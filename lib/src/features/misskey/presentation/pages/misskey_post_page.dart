// Misskey发布笔记页面
//
// 该文件包含MisskeyPostPage组件，用于创建和发布Misskey笔记。
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/misskey_repository.dart';
import '../../domain/drive_file.dart';
import '../../domain/drive_folder.dart';
import '../widgets/retryable_network_image.dart';

/// Misskey发布笔记页面组件
///
/// 用于创建和发布Misskey笔记，支持设置可见性、本地仅可见等选项，
/// 并提供预览功能。
class MisskeyPostPage extends ConsumerStatefulWidget {
  /// 创建一个新的MisskeyPostPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyPostPage({super.key});

  /// 创建MisskeyPostPage的状态管理对象
  @override
  ConsumerState<MisskeyPostPage> createState() => _MisskeyPostPageState();
}

/// MisskeyPostPage的状态管理类
class _MisskeyPostPageState extends ConsumerState<MisskeyPostPage> {
  /// 文本编辑控制器，用于管理笔记内容
  final TextEditingController _controller = TextEditingController();

  /// 是否显示预览
  bool _showPreview = false;

  /// 是否仅本地可见（不参与联邦）
  bool _localOnly = false;

  /// 笔记可见性，可选值：'public', 'home', 'followers', 'direct'
  String _visibility = 'public';

  /// 选中的附件列表
  final List<DriveFile> _attachments = [];

  /// 是否正在上传文件
  bool _isUploading = false;

  /// 是否正在发布笔记
  bool _isPosting = false;

  /// 释放资源
  ///
  ///  dispose文本编辑控制器资源。
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickLocalFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _isUploading = true);
      try {
        final repository = ref.read(misskeyRepositoryProvider);
        for (final file in result.files) {
          if (file.bytes != null) {
            final uploadedFile = await repository.uploadDriveFile(
              file.bytes!,
              file.name,
            );
            setState(() {
              _attachments.add(uploadedFile);
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading file: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  Future<void> _pickCloudFiles() async {
    final selectedFiles = await showDialog<List<DriveFile>>(
      context: context,
      builder: (context) => const _CloudFilePickerLoader(),
    );

    if (selectedFiles != null) {
      setState(() {
        // Avoid duplicates
        for (final file in selectedFiles) {
          if (!_attachments.any((a) => a.id == file.id)) {
            _attachments.add(file);
          }
        }
      });
    }
  }

  Future<void> _handlePost() async {
    if (_controller.text.isEmpty && _attachments.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      final repository = ref.read(misskeyRepositoryProvider);
      await repository.createNote(
        text: _controller.text.isEmpty ? null : _controller.text,
        fileIds: _attachments.map((a) => a.id).toList(),
        visibility: _visibility,
        localOnly: _localOnly,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('post_post_created'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  /// 构建发布笔记页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个居中的发布笔记对话框组件
  @override
  Widget build(BuildContext context) {
    // 用作对话框/模态框内容
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 顶部区域 ---
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'post_close'.tr(),
                      ),
                      const SizedBox(width: 8),
                      // 账户菜单
                      PopupMenuButton<String>(
                        tooltip: 'post_account'.tr(),
                        icon: const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 20),
                        ),
                        onSelected: (value) {
                          // 处理选择
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selected: $value')),
                          );
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'drafts',
                            child: Text('post_drafts'.tr()),
                          ),
                          PopupMenuItem(
                            value: 'scheduled',
                            child: Text('post_scheduled_posts'.tr()),
                          ),
                          PopupMenuItem(
                            value: 'switch',
                            child: Text('post_switch_account'.tr()),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // 可见性设置
                      PopupMenuButton<String>(
                        tooltip: 'post_visibility'.tr(),
                        icon: Icon(_getVisibilityIcon(_visibility)),
                        onSelected: (value) =>
                            setState(() => _visibility = value),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'public',
                            child: Text('post_visibility_public'.tr()),
                          ),
                          PopupMenuItem(
                            value: 'home',
                            child: Text('post_visibility_home'.tr()),
                          ),
                          PopupMenuItem(
                            value: 'followers',
                            child: Text('post_visibility_followers'.tr()),
                          ),
                          PopupMenuItem(
                            value: 'direct',
                            child: Text('post_visibility_direct'.tr()),
                          ),
                        ],
                      ),
                      // 仅本地可见
                      IconButton(
                        tooltip: 'post_local_only'.tr(),
                        icon: Icon(
                          _localOnly
                              ? Icons.rocket_launch
                              : Icons.rocket_launch_outlined,
                        ),
                        color: _localOnly
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        onPressed: () =>
                            setState(() => _localOnly = !_localOnly),
                      ),
                      const Spacer(),
                      // 其他选项菜单
                      PopupMenuButton<String>(
                        tooltip: 'post_other'.tr(),
                        icon: const Icon(Icons.more_horiz),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'reaction',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_box_outline_blank,
                                  size: 18,
                                ), // 模拟复选框
                                SizedBox(width: 8),
                                Text('post_accept_reactions'.tr()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'draft',
                            child: Text('post_save_to_drafts'.tr()),
                          ),
                          PopupMenuItem(
                            value: 'schedule',
                            child: Text('post_schedule_post'.tr()),
                          ),
                          PopupMenuItem(
                            value: 'preview',
                            child: Row(
                              children: [
                                Icon(
                                  _showPreview
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 18,
                                  color: _showPreview
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text('post_preview'.tr()),
                              ],
                            ),
                            onTap: () {
                              setState(() => _showPreview = !_showPreview);
                            },
                          ),
                          PopupMenuItem(
                            value: 'reset',
                            child: Text('post_reset'.tr()),
                            onTap: () {
                              setState(() {
                                _controller.clear();
                                _showPreview = false;
                                _localOnly = false;
                                _visibility = 'public';
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // 发布按钮
                      FilledButton(
                        onPressed: _isPosting || _isUploading ? null : _handlePost,
                        child: _isPosting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('post_publish'.tr()),
                      ),
                    ],
                  ),
                  const Divider(),

                  // --- 中间区域 ---
                  TextField(
                    controller: _controller,
                    maxLines: 8,
                    minLines: 4,
                    maxLength: 3000,
                    enabled: !_isPosting,
                    decoration: InputDecoration(
                      hintText: 'post_what_are_you_thinking'.tr(),
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      if (_showPreview) setState(() {});
                    },
                  ),

                  // 附件预览
                  if (_attachments.isNotEmpty || _isUploading) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _attachments.length + (_isUploading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _attachments.length) {
                            return const SizedBox(
                              width: 100,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final file = _attachments[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: file.thumbnailUrl != null || _isImage(file.type)
                                      ? RetryableNetworkImage(
                                          url: file.thumbnailUrl ?? file.url,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 100,
                                          height: 100,
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          child: const Icon(Icons.insert_drive_file),
                                        ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _attachments.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // 预览区域
                  if (_showPreview) ...[
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'post_preview'.tr(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _controller.text.isEmpty
                                ? 'post_preview_will_show_here'.tr()
                                : _controller.text,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),
                  ],

                  const Divider(),

                  // --- 底部区域 ---
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image_outlined),
                        tooltip: 'post_insert_attachment_from_local'.tr(),
                        onPressed: _isPosting ? null : _pickLocalFiles,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cloud_queue),
                        tooltip: 'post_insert_attachment_from_cloud'.tr(),
                        onPressed: _isPosting ? null : _pickCloudFiles,
                      ),
                      IconButton(
                        icon: const Icon(Icons.poll_outlined),
                        tooltip: 'post_poll'.tr(),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility_off_outlined),
                        tooltip: 'post_hide_content'.tr(),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.tag),
                        tooltip: 'post_tags'.tr(),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.alternate_email),
                        tooltip: 'post_mention'.tr(),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        tooltip: 'post_emoji'.tr(),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.code),
                        tooltip: 'post_mfm_format'.tr(),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
    );
  }

  /// 根据可见性值获取对应的图标
  ///
  /// [visibility] - 可见性字符串，可选值：'public', 'home', 'followers', 'direct'
  ///
  /// 返回对应的图标Data
  IconData _getVisibilityIcon(String visibility) {
    switch (visibility) {
      case 'home':
        return Icons.home;
      case 'followers':
        return Icons.lock_open;
      case 'direct':
        return Icons.mail;
      case 'public':
      default:
        return Icons.public;
    }
  }

  bool _isImage(String mimeType) {
    return mimeType.startsWith('image/');
  }
}

class _CloudFilePickerLoader extends StatelessWidget {
  const _CloudFilePickerLoader();

  @override
  Widget build(BuildContext context) {
    return const _CloudFilePicker();
  }
}

class _CloudFilePicker extends ConsumerStatefulWidget {
  const _CloudFilePicker();

  @override
  ConsumerState<_CloudFilePicker> createState() => _CloudFilePickerState();
}

class _CloudFilePickerState extends ConsumerState<_CloudFilePicker> {
  final List<DriveFile> _selectedFiles = [];
  String? _currentFolderId;

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(misskeyRepositoryProvider);

    return AlertDialog(
      title: Text('cloud_drive'.tr()),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  repository.getDriveFolders(folderId: _currentFolderId),
                  repository.getDriveFiles(folderId: _currentFolderId),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final folders = snapshot.data![0] as List<DriveFolder>;
                  final files = snapshot.data![1] as List<DriveFile>;

                  return ListView(
                    children: [
                      if (_currentFolderId != null)
                        ListTile(
                          leading: const Icon(Icons.arrow_back),
                          title: const Text('..'),
                          onTap: () => setState(() => _currentFolderId = null), // Simplify: only one level for now
                        ),
                      ...folders.map((folder) => ListTile(
                            leading: const Icon(Icons.folder),
                            title: Text(folder.name),
                            onTap: () => setState(() => _currentFolderId = folder.id),
                          )),
                      ...files.map((file) {
                        final isSelected = _selectedFiles.any((f) => f.id == file.id);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedFiles.add(file);
                              } else {
                                _selectedFiles.removeWhere((f) => f.id == file.id);
                              }
                            });
                          },
                          title: Text(file.name),
                          secondary: file.thumbnailUrl != null
                              ? RetryableNetworkImage(
                                  url: file.thumbnailUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.insert_drive_file),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cloud_cancel'.tr()),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedFiles),
          child: Text('cloud_close'.tr()),
        ),
      ],
    );
  }
}
