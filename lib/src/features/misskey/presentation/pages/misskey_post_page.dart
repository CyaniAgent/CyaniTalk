import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/misskey_repository.dart';

/// Misskey发布笔记页面组件
///
/// 用于创建和发布Misskey笔记，支持设置可见性、本地仅可见等选项，
/// 并提供预览功能。
class MisskeyPostPage extends ConsumerStatefulWidget {
  final String? channelId;

  /// 创建一个新的MisskeyPostPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  /// [channelId] - 可选的频道ID，如果提供，笔记将发布到该频道
  const MisskeyPostPage({super.key, this.channelId});

  /// 创建MisskeyPostPage的状态管理对象
  @override
  ConsumerState<MisskeyPostPage> createState() => _MisskeyPostPageState();
}

/// MisskeyPostPage的状态管理类
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _buildAttachIcon(
            Icons.image_outlined,
            'post_insert_attachment_from_local'.tr(),
          ),
          _buildAttachIcon(
            Icons.cloud_queue,
            'post_insert_attachment_from_cloud'.tr(),
          ),
          _buildAttachIcon(Icons.poll_outlined, 'post_poll'.tr()),
          _buildAttachIcon(
            Icons.visibility_off_outlined,
            'post_hide_content'.tr(),
          ),
          _buildAttachIcon(Icons.tag, 'post_tags'.tr()),
          _buildAttachIcon(Icons.alternate_email, 'post_mention'.tr()),
          _buildAttachIcon(Icons.emoji_emotions_outlined, 'post_emoji'.tr()),
          _buildAttachIcon(Icons.code, 'post_mfm_format'.tr()),
        ],
      ),
    );
  }

  Widget _buildAttachIcon(IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon, size: 22),
      tooltip: tooltip,
      onPressed: _isPosting ? null : () {},
    );
  }

  Future<void> _handlePublish() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      await repository.createNote(
        text: text,
        visibility: _visibility,
        localOnly: _localOnly,
        channelId: widget.channelId,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('post_post_created'.tr())));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
