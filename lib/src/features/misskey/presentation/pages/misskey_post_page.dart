// Misskey发布笔记页面
//
// 该文件包含MisskeyPostPage组件，用于创建和发布Misskey笔记。
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';

/// Misskey发布笔记页面组件
///
/// 用于创建和发布Misskey笔记，支持设置可见性、本地仅可见等选项，
/// 并提供预览功能。
class MisskeyPostPage extends StatefulWidget {
  /// 创建一个新的MisskeyPostPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyPostPage({super.key});

  /// 创建MisskeyPostPage的状态管理对象
  @override
  State<MisskeyPostPage> createState() => _MisskeyPostPageState();
}

/// MisskeyPostPage的状态管理类
class _MisskeyPostPageState extends State<MisskeyPostPage> {
  /// 文本编辑控制器，用于管理笔记内容
  final TextEditingController _controller = TextEditingController();

  /// 是否显示预览
  bool _showPreview = false;

  /// 是否仅本地可见（不参与联邦）
  bool _localOnly = false;

  /// 笔记可见性，可选值：'public', 'home', 'followers', 'direct'
  String _visibility = 'public';

  /// 释放资源
  ///
  ///  dispose文本编辑控制器资源。
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('post_post_created'.tr())),
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text('post_publish'.tr()),
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
                    decoration: InputDecoration(
                      hintText: 'post_what_are_you_thinking'.tr(),
                      border: InputBorder.none,
                    ),
                  ),

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
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.cloud_queue),
                        tooltip: 'post_insert_attachment_from_cloud'.tr(),
                        onPressed: () {},
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
}
