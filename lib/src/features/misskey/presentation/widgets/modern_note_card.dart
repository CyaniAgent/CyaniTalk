import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../domain/note.dart';
import '../../domain/mfm_renderer.dart';
import '../../data/misskey_repository.dart';
import '../../data/misskey_repository_interface.dart';
import '../../application/misskey_notifier.dart';
import '../../application/timeline_jump_provider.dart';
import 'retryable_network_image.dart';
import 'audio_player_widget.dart';
import '../../../common/presentation/pages/media_viewer_page.dart';

import '../../../common/presentation/widgets/media/media_item.dart';
import 'emoji_picker.dart';
import 'reaction_display.dart';

/// Modern NoteCard组件
///
/// 用于显示单个Misskey笔记的现代化卡片组件，采用卡片式布局，
/// 支持显示用户信息、文本内容、媒体文件和互动按钮。
///
/// @param note 要显示的笔记对象
class ModernNoteCard extends ConsumerStatefulWidget {
  final Note note;
  final String? timelineType;

  /// 创建ModernNoteCard组件
  ///
  /// @param key 组件的键
  /// @param note 要显示的笔记对象
  /// @param timelineType 可选的时间线类型，用于跳转功能
  const ModernNoteCard({super.key, required this.note, this.timelineType});

  @override
  ConsumerState<ModernNoteCard> createState() => _ModernNoteCardState();
}

class _ModernNoteCardState extends ConsumerState<ModernNoteCard> {
  bool _shouldAnimate = false;

  // MFM渲染器
  final MfmRenderer _mfmRenderer = MfmRenderer();

  @override
  void dispose() {
    _mfmRenderer.dispose();
    super.dispose();
  }

  /// 处理文本中的特殊格式
  ///
  /// 使用MFM渲染器处理文本中的各种特殊格式，并返回对应的TextSpan列表。
  List<TextSpan> _processText(String text, BuildContext context) {
    return _mfmRenderer.processText(text, context);
  }

  @override
  void initState() {
    super.initState();
    _shouldAnimate = false;
  }

  @override
  void didUpdateWidget(covariant ModernNoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only rebuild if the note has actually changed
    if (oldWidget.note.id != widget.note.id) {
      // 缓存管理由MfmRenderer内部处理
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final user = note.user;
    final text = note.text;
    final cw = note.cw;
    final theme = Theme.of(context);

    final card = RepaintBoundary(
      child: GestureDetector(
        onSecondaryTapDown: (details) =>
            _showContextMenu(details.globalPosition),
        onLongPressStart: (details) => _showContextMenu(details.globalPosition),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息行
                GestureDetector(
                  onTap: () {
                    if (user?.id != null) {
                      final me = ref.read(misskeyMeProvider).value;
                      if (me != null && me.id == user!.id) {
                        // Redirect to own profile tab
                        context.go('/profile');
                      } else {
                        context.push('/misskey/user/${user!.id}', extra: user);
                      }
                    }
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? Text(
                                user!.username.isNotEmpty
                                    ? user.username[0].toUpperCase()
                                    : '?',
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? user?.username ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (user?.host != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.public, size: 10),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        user!.host!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.secondary
                                              .withAlpha(179),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              '@${user?.username}${user?.host != null ? "@${user!.host}" : ""}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTime(note.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 如果是回复，显示原帖预览
                if (note.reply != null) ...[
                  _buildReplyPreview(note.reply!),
                  const SizedBox(height: 12),
                ],

                // CW (Content Warning) 或正文内容
                if (cw != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: SelectableText(cw)),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else if (text != null) ...[
                  SelectableText.rich(
                    TextSpan(
                      children: _processText(text, context),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // 附件内容
                if (note.files.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildMediaGrid(note.files),
                  ),

                const SizedBox(height: 8),

                // 显示表情反应
                if (note.reactions.isNotEmpty)
                  FutureBuilder<IMisskeyRepository>(
                    future: ref.read(misskeyRepositoryProvider.future),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final repository = snapshot.data!;
                        return ReactionDisplay(
                          note: note,
                          host: repository.host,
                          onReactionTap: (reaction) async {
                            try {
                              final repository = await ref.read(
                                misskeyRepositoryProvider.future,
                              );

                              // 检查是否是取消自己的表情反应
                              if (note.myReaction == reaction) {
                                await repository.removeReaction(note.id);
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'note_reaction_removed'.tr(),
                                        ),
                                      ),
                                    );
                                  }
                                });
                              } else if (note.myReaction != null) {
                                // 如果已经有其他表情反应，先取消再发送新的
                                await repository.removeReaction(note.id);
                                await repository.addReaction(note.id, reaction);
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'note_reaction_updated'.tr(),
                                        ),
                                      ),
                                    );
                                  }
                                });
                              } else {
                                // 直接发送表情反应
                                await repository.addReaction(note.id, reaction);
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'note_reaction_added'.tr(),
                                        ),
                                      ),
                                    );
                                  }
                                });
                              }
                            } catch (e) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'note_failed_to_react'.tr(
                                          namedArgs: {'error': e.toString()},
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              });
                            }
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),

                const SizedBox(height: 16),

                // 交互按钮行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 回复按钮
                    Expanded(
                      child: _buildAction(
                        Icons.reply,
                        note.repliesCount.toString(),
                        _handleReply,
                        tooltip: 'Reply',
                      ),
                    ),

                    // 转发按钮
                    Expanded(
                      child: _buildAction(
                        Icons.repeat,
                        note.renoteCount.toString(),
                        _handleRenote,
                        tooltip: 'Renote',
                      ),
                    ),

                    // 反应按钮
                    Expanded(
                      child: _buildAction(
                        Icons.add_reaction_outlined,
                        note.reactions.length.toString(),
                        _handleReaction,
                        tooltip: 'Reaction',
                      ),
                    ),

                    // 更多按钮
                    Expanded(
                      child: _buildAction(
                        Icons.more_vert,
                        "",
                        _showContextMenuFromButton,
                        tooltip: 'More',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (_shouldAnimate) {
      return card
          .animate(
            onComplete: (controller) {
              // 动画完成后通知组件不再需要为了动效而特殊处理
              if (mounted) {
                setState(() {
                  _shouldAnimate = false;
                });
              }
            },
          )
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
    }

    return card;
  }

  void _showContextMenuFromButton() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = Offset(
      button.localToGlobal(Offset.zero).dx + button.size.width,
      button.localToGlobal(Offset.zero).dy + button.size.height / 2,
    );

    _showContextMenu(position);
  }

  void _showContextMenu(Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20),
              const SizedBox(width: 12),
              Text('post_menu_details'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy_content',
          child: Row(
            children: [
              const Icon(Icons.copy, size: 20),
              const SizedBox(width: 12),
              Text('post_menu_copy_content'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy_link',
          child: Row(
            children: [
              const Icon(Icons.link, size: 20),
              const SizedBox(width: 12),
              Text('post_menu_copy_link'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          enabled: false,
          value: 'embed',
          child: Row(
            children: [
              const Icon(Icons.code, size: 20),
              const SizedBox(width: 12),
              Text('post_menu_embed'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              const Icon(Icons.share, size: 20),
              const SizedBox(width: 12),
              Text('post_menu_share'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'bookmark',
          child: Row(
            children: [
              const Icon(Icons.bookmark_border, size: 20),
              const SizedBox(width: 12),
              Text('post_menu_bookmark'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'add_note',
          child: Row(
            children: [
              const Icon(Icons.reply, size: 20),
              const SizedBox(width: 12),
              Text('post_menu_add_note'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              const Icon(Icons.flag_outlined, size: 20, color: Colors.red),
              const SizedBox(width: 12),
              Text(
                'post_menu_report'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy_id',
          child: Row(
            children: [
              const Icon(Icons.copy_all, size: 20),
              const SizedBox(width: 12),
              Text('post_menu_copy_id'.tr()),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value);
      }
    });
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'details':
        _showDetails();
        break;
      case 'copy_content':
        if (widget.note.text != null) {
          Clipboard.setData(ClipboardData(text: widget.note.text!));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('post_copied'.tr())));
        }
        break;
      case 'copy_link':
        _copyLink();
        break;
      case 'share':
        _handleShare();
        break;
      case 'bookmark':
        _handleBookmark();
        break;
      case 'add_note':
        _handleReply();
        break;
      case 'report':
        _handleReport();
        break;
      case 'copy_id':
        Clipboard.setData(ClipboardData(text: widget.note.id));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('post_id_copied'.tr())));
        break;
    }
  }

  void _showDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('post_details'.tr()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText('ID: ${widget.note.id}'),
              const SizedBox(height: 8),
              SelectableText('Created: ${widget.note.createdAt}'),
              const SizedBox(height: 8),
              SelectableText('User: ${widget.note.user?.username}'),
              const SizedBox(height: 8),
              const Text('Raw Data (Debug):'),
              SelectableText(widget.note.toString()), // Simple dump for now
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _copyLink() async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final host = repository.host;
      final url = 'https://$host/notes/${widget.note.id}';
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('post_link_copied'.tr())));
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _handleBookmark() async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      await repository.bookmark(widget.note.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('post_bookmarked'.tr())));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'post_bookmark_failed'.tr(namedArgs: {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleReport() async {
    final textController = TextEditingController();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('post_report'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('post_report_description'.tr()),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'post_report_reason'.tr(),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () async {
              final reason = textController.text;
              if (reason.isEmpty) return;

              Navigator.pop(dialogContext);
              try {
                final repository = await ref.read(
                  misskeyRepositoryProvider.future,
                );
                if (widget.note.user != null) {
                  await repository.report(
                    widget.note.id,
                    widget.note.user!.id,
                    reason,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('post_reported'.tr())),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('post_report_failed'.tr())),
                  );
                }
              }
            },
            child: Text('report'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    IconData icon,
    String label,
    VoidCallback onTap, {
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onTap,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          if (label.isNotEmpty)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      tooltip: tooltip,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months个月前';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years年前';
    }
  }

  bool _isImageFile(String? mimeType, String url) {
    if (mimeType != null) {
      if (mimeType.startsWith('image/')) return true;
      if (mimeType.startsWith('video/') || mimeType.startsWith('audio/')) {
        return false;
      }
    }
    final ext = url.toLowerCase().split('.').last.split('?').first;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'].contains(ext);
  }

  bool _isVideoFile(String? mimeType, String url) {
    if (mimeType != null) {
      if (mimeType.startsWith('video/')) return true;
      if (mimeType.startsWith('image/') || mimeType.startsWith('audio/')) {
        return false;
      }
    }
    final ext = url.toLowerCase().split('.').last.split('?').first;
    return ['mp4', 'webm', 'mov', 'avi', 'mkv', 'm4v'].contains(ext);
  }

  bool _isAudioFile(String? mimeType, String url) {
    if (mimeType != null) {
      if (mimeType.startsWith('audio/')) return true;
      if (mimeType.startsWith('image/') || mimeType.startsWith('video/')) {
        return false;
      }
    }
    final ext = url.toLowerCase().split('.').last.split('?').first;
    return ['mp3', 'wav', 'ogg', 'aac', 'm4a', 'flac'].contains(ext);
  }

  Future<void> _handleRenote() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('转发确认'),
        content: Text('确定要转发这条消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repository = await ref.read(
                  misskeyRepositoryProvider.future,
                );
                await repository.renote(widget.note.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('note_renoted_successfully'.tr())),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'note_failed_to_renote'.tr(
                          namedArgs: {'error': e.toString()},
                        ),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReply() async {
    final textController = TextEditingController();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('note_reply'.tr()),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: 'note_what_on_your_mind'.tr()),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('note_cancel'.tr()),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repository = await ref.read(
                  misskeyRepositoryProvider.future,
                );
                await repository.reply(widget.note.id, textController.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('note_reply_sent'.tr())),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'note_failed_to_reply'.tr(
                          namedArgs: {'error': e.toString()},
                        ),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text('note_reply'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReaction() async {
    // 弹出表情选择器
    showDialog(
      context: context,
      builder: (dialogContext) {
        return EmojiPicker(
          noteId: widget.note.id,
          onEmojiSelected: (emoji) async {
            try {
              final repository = await ref.read(
                misskeyRepositoryProvider.future,
              );
              await repository.addReaction(widget.note.id, emoji);
              // 使用局部上下文变量，避免在异步操作中使用可能失效的 BuildContext
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('note_reaction_added'.tr())),
                );
              }
            } catch (e) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'note_failed_to_react'.tr(
                        namedArgs: {'error': e.toString()},
                      ),
                    ),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  void _handleShare() {
    // Placeholder for share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('note_share_coming_soon'.tr())));
  }

  /// 构建回复原帖预览

  Widget _buildReplyPreview(Note replyNote) {
    return Card(
      elevation: 0,

      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),

      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),

        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,

          width: 1,
        ),
      ),

      child: InkWell(
        onTap: () {
          if (widget.timelineType != null && widget.note.replyId != null) {
            ref
                    .read(timelineJumpProvider(widget.timelineType!).notifier)
                    .state =
                widget.note.replyId;
          }
        },

        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,

                width: 4,
              ),
            ),
          ),

          padding: const EdgeInsets.all(12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 8,

                    backgroundImage: replyNote.user?.avatarUrl != null
                        ? NetworkImage(replyNote.user!.avatarUrl!)
                        : null,

                    child: replyNote.user?.avatarUrl == null
                        ? const Icon(Icons.person, size: 10)
                        : null,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Text(
                          replyNote.user?.name ??
                              replyNote.user?.username ??
                              'Unknown',

                          style: TextStyle(
                            fontSize: 12,

                            fontWeight: FontWeight.bold,

                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),

                          overflow: TextOverflow.ellipsis,
                        ),

                        if (replyNote.user?.host != null)
                          Text(
                            replyNote.user!.host!,

                            style: TextStyle(
                              fontSize: 9,

                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),

                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                replyNote.text ?? replyNote.cw ?? '',

                maxLines: 3,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: 12,

                  color: Theme.of(context).colorScheme.onSurfaceVariant,

                  height: 1.4,
                ),
              ),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建媒体网格，根据媒体文件数量调整布局
  Widget _buildMediaGrid(List<Map<String, dynamic>> files) {
    // 过滤出图片和视频文件
    final mediaFiles = files.where((file) {
      final url = file['url'] as String?;
      final type = file['type'] as String?;
      if (url == null) return false;
      return _isImageFile(type, url) || _isVideoFile(type, url);
    }).toList();

    // 如果没有图片或视频，只显示音频
    if (mediaFiles.isEmpty) {
      return Column(
        children: files.map((file) {
          final url = file['url'] as String?;
          final type = file['type'] as String?;
          final name = file['name'] as String?;

          if (url == null) return const SizedBox.shrink();

          final isAudio = _isAudioFile(type, url);
          if (isAudio) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AudioPlayerWidget(audioUrl: url, fileName: name),
            );
          }

          return const SizedBox.shrink();
        }).toList(),
      );
    }

    // 根据媒体文件数量选择不同的布局
    if (mediaFiles.length == 1) {
      // 单个媒体文件
      final file = mediaFiles[0];
      return _buildSingleMedia(file);
    } else if (mediaFiles.length == 2) {
      // 两个媒体文件，水平排列
      return _buildTwoMedia(mediaFiles);
    } else if (mediaFiles.length == 3) {
      // 三个媒体文件，一个大图加两个小图
      return _buildThreeMedia(mediaFiles);
    } else if (mediaFiles.length == 4) {
      // 四个媒体文件，2x2网格
      return _buildFourMedia(mediaFiles);
    } else {
      // 五个或更多媒体文件，使用2列网格
      return _buildMultipleMedia(mediaFiles);
    }
  }

  /// 构建单个媒体文件的显示
  Widget _buildSingleMedia(Map<String, dynamic> file) {
    final url = file['url'] as String?;
    final type = file['type'] as String?;

    if (url == null) return const SizedBox.shrink();

    final isImage = _isImageFile(type, url);
    final isVideo = _isVideoFile(type, url);
    final thumbnailUrl = file['thumbnailUrl'] as String? ?? url;

    if (isVideo) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onTap: () {
              // 收集笔记中的所有媒体文件
              final mediaItems = <MediaItem>[];
              int initialIndex = 0;

              for (int i = 0; i < widget.note.files.length; i++) {
                final file = widget.note.files[i];
                final fileUrl = file['url'] as String;
                final fileType = file['type'] as String;
                final isImage = fileType.startsWith('image/');
                final isVideo = fileType.startsWith('video/');
                final isAudio = fileType.startsWith('audio/');

                if (isImage) {
                  mediaItems.add(
                    MediaItem(
                      url: fileUrl,
                      type: MediaType.image,
                      fileName: file['name'] as String?,
                    ),
                  );
                  if (fileUrl == url) {
                    initialIndex = mediaItems.length - 1;
                  }
                } else if (isVideo) {
                  mediaItems.add(
                    MediaItem(
                      url: fileUrl,
                      type: MediaType.video,
                      fileName: file['name'] as String?,
                    ),
                  );
                  if (fileUrl == url) {
                    initialIndex = mediaItems.length - 1;
                  }
                } else if (isAudio) {
                  mediaItems.add(
                    MediaItem(url: fileUrl, type: MediaType.audio),
                  );
                  if (fileUrl == url) {
                    initialIndex = mediaItems.length - 1;
                  }
                }
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MediaViewerPage(
                    mediaItems: mediaItems,
                    initialIndex: initialIndex,
                  ),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                RetryableNetworkImage(
                  url: thumbnailUrl,
                  width: 160, // 增加单个图片的宽度
                  height: 160, // 增加单个图片的高度
                  fit: BoxFit.cover,
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.surface,
                    size: 48,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (isImage) {
      final heroTag = 'image_${url}_${widget.note.id}';
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onTap: () {
              // 收集笔记中的所有图片
              final mediaItems = <MediaItem>[];
              int initialIndex = 0;

              for (int i = 0; i < widget.note.files.length; i++) {
                final file = widget.note.files[i];
                final fileUrl = file['url'] as String;
                final fileType = file['type'] as String;
                final isImage = fileType.startsWith('image/');
                final isVideo = fileType.startsWith('video/');
                final isAudio = fileType.startsWith('audio/');

                if (isImage) {
                  mediaItems.add(
                    MediaItem(
                      url: fileUrl,
                      type: MediaType.image,
                      fileName: file['name'] as String?,
                    ),
                  );
                  if (fileUrl == url) {
                    initialIndex = mediaItems.length - 1;
                  }
                } else if (isVideo) {
                  mediaItems.add(
                    MediaItem(
                      url: fileUrl,
                      type: MediaType.video,
                      fileName: file['name'] as String?,
                    ),
                  );
                  if (fileUrl == url) {
                    initialIndex = mediaItems.length - 1;
                  }
                } else if (isAudio) {
                  mediaItems.add(
                    MediaItem(url: fileUrl, type: MediaType.audio),
                  );
                  if (fileUrl == url) {
                    initialIndex = mediaItems.length - 1;
                  }
                }
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MediaViewerPage(
                    mediaItems: mediaItems,
                    initialIndex: initialIndex,
                    heroTag: heroTag,
                  ),
                ),
              );
            },
            child: Hero(
              tag: heroTag,
              child: RetryableNetworkImage(
                url: thumbnailUrl,
                width: 160, // 增加单个图片的宽度
                height: 160, // 增加单个图片的高度
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 构建两个媒体文件的显示（水平排列）
  Widget _buildTwoMedia(List<Map<String, dynamic>> files) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: _buildMediaThumbnail(files[0], width: 0, height: 100),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildMediaThumbnail(files[1], width: 0, height: 100),
          ),
        ],
      ),
    );
  }

  /// 构建三个媒体文件的显示（一个大图加两个小图）
  Widget _buildThreeMedia(List<Map<String, dynamic>> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMediaThumbnail(files[0], width: double.infinity, height: 120),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildMediaThumbnail(files[1], width: 0, height: 80),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildMediaThumbnail(files[2], width: 0, height: 80),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建四个媒体文件的显示（2x2网格）
  Widget _buildFourMedia(List<Map<String, dynamic>> files) {
    return SizedBox(
      height: 204, // 100 * 2 + 4 gap
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildMediaThumbnail(files[0], width: 0, height: 100),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildMediaThumbnail(files[1], width: 0, height: 100),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildMediaThumbnail(files[2], width: 0, height: 100),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildMediaThumbnail(files[3], width: 0, height: 100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建多个媒体文件的显示（2列网格）
  Widget _buildMultipleMedia(List<Map<String, dynamic>> files) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // 避免与外层滚动冲突
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        return _buildMediaThumbnail(files[index], width: 0, height: 100);
      },
    );
  }

  /// 构建单个媒体缩略图
  Widget _buildMediaThumbnail(
    Map<String, dynamic> file, {
    double width = 100,
    double height = 100,
  }) {
    final url = file['url'] as String?;
    final type = file['type'] as String?;

    if (url == null) return const SizedBox.shrink();

    final isImage = _isImageFile(type, url);
    final isVideo = _isVideoFile(type, url);
    final thumbnailUrl = file['thumbnailUrl'] as String? ?? url;

    if (isVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () {
            // 收集笔记中的所有媒体文件
            final mediaItems = <MediaItem>[];
            int initialIndex = 0;

            for (int i = 0; i < widget.note.files.length; i++) {
              final file = widget.note.files[i];
              final fileUrl = file['url'] as String;
              final fileType = file['type'] as String;
              final isImage = fileType.startsWith('image/');
              final isVideo = fileType.startsWith('video/');
              final isAudio = fileType.startsWith('audio/');

              if (isImage) {
                mediaItems.add(MediaItem(url: fileUrl, type: MediaType.image));
                if (fileUrl == url) {
                  initialIndex = mediaItems.length - 1;
                }
              } else if (isVideo) {
                mediaItems.add(MediaItem(url: fileUrl, type: MediaType.video));
                if (fileUrl == url) {
                  initialIndex = mediaItems.length - 1;
                }
              } else if (isAudio) {
                mediaItems.add(
                  MediaItem(
                    url: fileUrl,
                    type: MediaType.audio,
                    fileName: file['name'] as String?,
                  ),
                );
                if (fileUrl == url) {
                  initialIndex = mediaItems.length - 1;
                }
              }
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MediaViewerPage(
                  mediaItems: mediaItems,
                  initialIndex: initialIndex,
                ),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              RetryableNetworkImage(
                url: thumbnailUrl,
                width: width > 0 ? width : null,
                height: height,
                fit: BoxFit.cover,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isImage) {
      final heroTag = 'image_${url}_${widget.note.id}';
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () {
            // 收集笔记中的所有图片
            final mediaItems = <MediaItem>[];
            int initialIndex = 0;

            for (int i = 0; i < widget.note.files.length; i++) {
              final file = widget.note.files[i];
              final fileUrl = file['url'] as String;
              final fileType = file['type'] as String;
              final isImage = fileType.startsWith('image/');
              final isVideo = fileType.startsWith('video/');
              final isAudio = fileType.startsWith('audio/');

              if (isImage) {
                mediaItems.add(MediaItem(url: fileUrl, type: MediaType.image));
                if (fileUrl == url) {
                  initialIndex = mediaItems.length - 1;
                }
              } else if (isVideo) {
                mediaItems.add(MediaItem(url: fileUrl, type: MediaType.video));
                if (fileUrl == url) {
                  initialIndex = mediaItems.length - 1;
                }
              } else if (isAudio) {
                mediaItems.add(
                  MediaItem(
                    url: fileUrl,
                    type: MediaType.audio,
                    fileName: file['name'] as String?,
                  ),
                );
                if (fileUrl == url) {
                  initialIndex = mediaItems.length - 1;
                }
              }
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MediaViewerPage(
                  mediaItems: mediaItems,
                  initialIndex: initialIndex,
                  heroTag: heroTag,
                ),
              ),
            );
          },
          child: Hero(
            tag: heroTag,
            child: RetryableNetworkImage(
              url: thumbnailUrl,
              width: width > 0 ? width : null,
              height: height,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
