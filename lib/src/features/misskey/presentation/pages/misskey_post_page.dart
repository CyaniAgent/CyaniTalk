import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/features/misskey/application/file_upload_notifier.dart';
import '/src/features/misskey/domain/upload_task.dart';
import '/src/features/misskey/presentation/widgets/attachment_card.dart';
import '/src/features/misskey/presentation/widgets/drive_file_picker.dart'
    show showDriveFilePicker;

/// Misskey 发布笔记页面组件
///
/// 用于创建和发布 Misskey 笔记，支持设置可见性、本地仅可见等选项，
/// 并提供预览功能。
class MisskeyPostPage extends ConsumerStatefulWidget {
  final String? channelId;

  /// 创建一个新的 MisskeyPostPage 实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  /// [channelId] - 可选的频道 ID，如果提供，笔记将发布到该频道
  const MisskeyPostPage({super.key, this.channelId});

  /// 创建 MisskeyPostPage 的状态管理对象
  @override
  ConsumerState<MisskeyPostPage> createState() => _MisskeyPostPageState();
}

/// MisskeyPostPage 的状态管理类
class _MisskeyPostPageState extends ConsumerState<MisskeyPostPage> {
  final TextEditingController _controller = TextEditingController();
  bool _showPreview = false;
  bool _localOnly = false;
  String _visibility = 'public';
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 处理从本地选择文件
  Future<void> _pickLocalFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          // 图片
          'jpg', 'jpeg', 'png', 'gif', 'webp',
          // 视频
          'mp4', 'webm', 'mov',
          // 音频
          'mp3', 'wav', 'ogg',
          // 文档
          'pdf', 'txt', 'doc', 'docx',
          // 压缩包
          'zip', 'rar', '7z',
        ],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            final localFile = File(file.path!);
            // 添加到上传队列
            ref.read(fileUploadProvider.notifier).addLocalFile(localFile);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('attachment_pick_failed'.tr(args: [e.toString()])),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 处理从云盘选择文件
  Future<void> _pickCloudFile() async {
    if (!mounted) return;

    // 使用 MD3 Bottom Sheet 显示云盘文件选择器
    final selectedFiles = await showDriveFilePicker(
      context: context,
      maxFiles: 16,
    );

    // 处理选中的文件
    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      final notifier = ref.read(fileUploadProvider.notifier);
      for (final file in selectedFiles) {
        // 添加已有的 DriveFile（状态为成功）
        notifier.addExistingDriveFile(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return _buildMobileLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  /// 构建移动端全屏布局
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'post_close'.tr(),
        ),
        title: Text('post_publish'.tr()),
        actions: [
          if (_isPosting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilledButton(
                onPressed: _handlePublish,
                child: Text('post_publish'.tr()),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildToolBar(context),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(child: _buildInputArea(context)),
          ),
          const Divider(height: 1),
          _buildAttachmentBar(context),
        ],
      ),
    );
  }

  /// 构建桌面端卡片布局
  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDesktopHeader(context),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(child: _buildInputArea(context)),
              ),
              const Divider(height: 1),
              _buildAttachmentBar(context),
            ],
          ),
        ),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
    );
  }

  /// 桌面端特定的头部
  Widget _buildDesktopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'post_close'.tr(),
          ),
          const Spacer(),
          _buildToolBar(context),
          const SizedBox(width: 8),
          if (_isPosting)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            FilledButton(
              onPressed: _handlePublish,
              child: Text('post_publish'.tr()),
            ),
        ],
      ),
    );
  }

  /// 通用工具栏 (账户、可见性、本地可见、更多)
  Widget _buildToolBar(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 账户菜单
        PopupMenuButton<String>(
          tooltip: 'post_account'.tr(),
          icon: const CircleAvatar(
            radius: 14,
            child: Icon(Icons.person, size: 18),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'drafts', child: Text('post_drafts'.tr())),
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
        // 可见性设置
        PopupMenuButton<String>(
          tooltip: 'post_visibility'.tr(),
          icon: Icon(_getVisibilityIcon(_visibility), size: 20),
          onSelected: (value) => setState(() => _visibility = value),
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
            _localOnly ? Icons.rocket_launch : Icons.rocket_launch_outlined,
            size: 20,
          ),
          color: _localOnly ? Theme.of(context).colorScheme.primary : null,
          onPressed: () => setState(() => _localOnly = !_localOnly),
        ),
        // 更多选项
        PopupMenuButton<String>(
          tooltip: 'post_other'.tr(),
          icon: const Icon(Icons.more_horiz, size: 20),
          itemBuilder: (context) => [
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
              onTap: () => setState(() => _showPreview = !_showPreview),
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
      ],
    );
  }

  /// 输入区域 (文本框 + 预览)
  Widget _buildInputArea(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            maxLines: null,
            minLines: 5,
            maxLength: 3000,
            autofocus: true,
            enabled: !_isPosting,
            decoration: InputDecoration(
              hintText: 'post_what_are_you_thinking'.tr(),
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (text) {
              if (_showPreview) setState(() {});
            },
          ),
          if (_showPreview) ...[
            const SizedBox(height: 16),
            const Divider(),
            _buildPreviewArea(context),
          ],
        ],
      ),
    );
  }

  /// 预览区域
  Widget _buildPreviewArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'post_preview'.tr(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _controller.text.isEmpty
                ? 'post_preview_will_show_here'.tr()
                : _controller.text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  /// 底部附件栏
  Widget _buildAttachmentBar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 附件列表
        _buildAttachmentList(context),

        // 工具栏按钮
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _buildAttachIcon(
                Icons.image_outlined,
                'post_insert_attachment_from_local'.tr(),
                onPressed: _pickLocalFile,
              ),
              _buildAttachIcon(
                Icons.cloud_queue,
                'post_insert_attachment_from_cloud'.tr(),
                onPressed: _pickCloudFile,
              ),
              _buildAttachIcon(Icons.poll_outlined, 'post_poll'.tr()),
              _buildAttachIcon(
                Icons.visibility_off_outlined,
                'post_hide_content'.tr(),
              ),
              _buildAttachIcon(Icons.tag, 'post_tags'.tr()),
              _buildAttachIcon(Icons.alternate_email, 'post_mention'.tr()),
              _buildAttachIcon(
                Icons.emoji_emotions_outlined,
                'post_emoji'.tr(),
              ),
              _buildAttachIcon(Icons.code, 'post_mfm_format'.tr()),
            ],
          ),
        ),
      ],
    );
  }

  /// 附件列表显示区域
  Widget _buildAttachmentList(BuildContext context) {
    final uploadTasks = ref.watch(fileUploadProvider);

    if (uploadTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: uploadTasks.length,
        itemBuilder: (context, index) {
          final task = uploadTasks[index];
          return AttachmentCard(
            task: task,
            onRemove: () {
              ref.read(fileUploadProvider.notifier).removeTask(task.id);
            },
            onRetry: () {
              ref.read(fileUploadProvider.notifier).retryTask(task.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildAttachIcon(
    IconData icon,
    String tooltip, {
    VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 22),
      tooltip: tooltip,
      onPressed: _isPosting || onPressed == null ? null : onPressed,
    );
  }

  Future<void> _handlePublish() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 检查是否有上传失败的任务
    final uploadTasks = ref.read(fileUploadProvider);
    final failedTasks = uploadTasks
        .where((task) => task.status == UploadStatus.failed)
        .toList();

    if (failedTasks.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('attachment_upload_failed_warning'.tr()),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'attachment_retry'.tr(),
              onPressed: () {
                for (final task in failedTasks) {
                  ref.read(fileUploadProvider.notifier).retryTask(task.id);
                }
              },
            ),
          ),
        );
      }
      return;
    }

    // 检查是否有正在上传的任务
    final uploadingTasks = uploadTasks
        .where(
          (task) =>
              task.status == UploadStatus.uploading ||
              task.status == UploadStatus.pending ||
              task.status == UploadStatus.retrying,
        )
        .toList();

    if (uploadingTasks.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('attachment_still_uploading'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isPosting = true);

    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);

      // 获取已上传成功的文件 ID
      final fileIds = ref
          .read(fileUploadProvider.notifier)
          .getUploadedFileIds();

      await repository.createNote(
        text: text,
        visibility: _visibility,
        localOnly: _localOnly,
        channelId: widget.channelId,
        fileIds: fileIds.isNotEmpty ? fileIds : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('post_post_created'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 清除已完成的上传任务
        ref.read(fileUploadProvider.notifier).clearCompletedTasks();

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

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
}
