// Misskey发布笔记页面
//
// 该文件包含MisskeyPostPage组件，用于创建和发布Misskey笔记。
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
                        tooltip: '关闭',
                      ),
                      const SizedBox(width: 8),
                      // 账户菜单
                      PopupMenuButton<String>(
                        tooltip: '账户',
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
                          const PopupMenuItem(
                            value: 'drafts',
                            child: Text('草稿列表'),
                          ),
                          const PopupMenuItem(
                            value: 'scheduled',
                            child: Text('定时发布列表'),
                          ),
                          const PopupMenuItem(
                            value: 'switch',
                            child: Text('切换账户'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // 可见性设置
                      PopupMenuButton<String>(
                        tooltip: '可见性',
                        icon: Icon(_getVisibilityIcon(_visibility)),
                        onSelected: (value) =>
                            setState(() => _visibility = value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'public',
                            child: Text('公开'),
                          ),
                          const PopupMenuItem(
                            value: 'home',
                            child: Text('首页'),
                          ),
                          const PopupMenuItem(
                            value: 'followers',
                            child: Text('关注者'),
                          ),
                          const PopupMenuItem(
                            value: 'direct',
                            child: Text('仅提及'),
                          ),
                        ],
                      ),
                      // 仅本地可见
                      IconButton(
                        tooltip: '不参与联邦',
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
                        tooltip: '其他',
                        icon: const Icon(Icons.more_horiz),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'reaction',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_box_outline_blank,
                                  size: 18,
                                ), // 模拟复选框
                                SizedBox(width: 8),
                                Text('接受表情反应'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'draft',
                            child: Text('保存到草稿'),
                          ),
                          const PopupMenuItem(
                            value: 'schedule',
                            child: Text('定时发布'),
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
                                const Text('预览'),
                              ],
                            ),
                            onTap: () {
                              setState(() => _showPreview = !_showPreview);
                            },
                          ),
                          PopupMenuItem(
                            value: 'reset',
                            child: const Text('重置'),
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
                            const SnackBar(content: Text('已发布!')),
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('发布'),
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
                    decoration: const InputDecoration(
                      hintText: '你在想什么？',
                      border: InputBorder.none,
                    ),
                  ),

                  // 预览区域
                  if (_showPreview) ...[
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '预览',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _controller.text.isEmpty
                                ? '(预览将显示在这里)'
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
                        tooltip: '从本地插入附件',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.cloud_queue),
                        tooltip: '从云存储插入附件',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.poll_outlined),
                        tooltip: '投票',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility_off_outlined),
                        tooltip: '隐藏内容',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.tag),
                        tooltip: '标签',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.alternate_email),
                        tooltip: '提及',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        tooltip: '表情',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.code),
                        tooltip: 'MFM格式',
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
