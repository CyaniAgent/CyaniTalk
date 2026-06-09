import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '/src/core/utils/logger.dart';
import '/src/features/misskey/domain/note.dart';
import '/src/features/misskey/domain/mfm_renderer.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/features/misskey/data/misskey_repository_interface.dart';
import '/src/features/misskey/presentation/widgets/poll_card.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import 'retryable_network_image.dart';
import 'audio_player_widget.dart';
import 'cached_misskey_avatar.dart';
import '/src/features/common/presentation/pages/media_viewer_page.dart';

import '/src/features/common/presentation/widgets/media/media_item.dart';
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
  final bool isHighlighted;
  final VoidCallback? onHighlightEnd;

  /// 创建ModernNoteCard组件
  ///
  /// @param key 组件的键
  /// @param note 要显示的笔记对象
  /// @param timelineType 可选的时间线类型，用于跳转功能
  const ModernNoteCard({
    super.key,
    required this.note,
    this.timelineType,
    this.isHighlighted = false,
    this.onHighlightEnd,
  });

  @override
  ConsumerState<ModernNoteCard> createState() => _ModernNoteCardState();
}

class _ModernNoteCardState extends ConsumerState<ModernNoteCard> {
  Timer? _highlightTimer;
  bool _isCwExpanded = false;

  // MFM渲染器
  final MfmRenderer _mfmRenderer = MfmRenderer();

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _mfmRenderer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setupMfmRenderer();
    _loadEmojis();
    _scheduleHighlightEnd();
  }

  @override
  void didUpdateWidget(covariant ModernNoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      _loadEmojis();
    }
    if (oldWidget.isHighlighted != widget.isHighlighted) {
      _scheduleHighlightEnd();
    }
  }

  void _scheduleHighlightEnd() {
    if (widget.isHighlighted && widget.onHighlightEnd != null) {
      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(seconds: 3), () {
        widget.onHighlightEnd?.call();
      });
    }
  }

  /// 设置MFM渲染器
  void _setupMfmRenderer() {
    // 设置API表情加载器
    _mfmRenderer.setApiEmojiLoader((emojiName) async {
      try {
        final repository = await ref.read(misskeyRepositoryProvider.future);
        final emojiDetail = await repository.getEmoji(emojiName);
        return emojiDetail.url;
      } catch (e) {
        logger.error('Error loading emoji from API: $e');
        return null;
      }
    });
  }

  /// 加载笔记中的表情到MFM渲染器缓存
  void _loadEmojis() {
    final note = widget.note;

    // 加载笔记中的表情
    if (note.emojis != null && note.emojis!.isNotEmpty) {
      _mfmRenderer.addEmojisToCache(note.emojis!);
    }

    // 加载用户的表情
    if (note.user?.emojis != null && note.user!.emojis!.isNotEmpty) {
      _mfmRenderer.addEmojisToCache(note.user!.emojis!);
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
                      if (user != null)
                        CachedMisskeyAvatar(
                          userId: user.id,
                          avatarUrl: user.avatarUrl ?? '',
                          host: user.host,
                          radius: 20,
                          currentUserId: ref.read(misskeyMeProvider).value?.id,
                          onTap: () {
                            final me = ref.read(misskeyMeProvider).value;
                            if (me != null && me.id == user.id) {
                            context.go('/profile');
                          } else {
                            context.push('/misskey/user/${user.id}', extra: user);
                          }
                          },
                        )
                      else
                        CircleAvatar(
                          radius: 20,
                          child: Text(
                            user?.username.isNotEmpty == true
                                ? user!.username[0].toUpperCase()
                                : '?',
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _mfmRenderer.processTextToRichText(
                              user?.name ?? user?.username ?? 'Unknown',
                              context,
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              onEmojiLoaded: () {
                                if (mounted) setState(() {});
                              },
                            ),
                            Text.rich(
                              TextSpan(
                                text: '@${user?.username}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                children: user?.host != null
                                    ? [
                                        TextSpan(
                                          text: '@${user!.host}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                                          ),
                                        ),
                                      ]
                                    : null,
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

                // CW (Content Warning) 可展开区域
                if (cw != null) ...[
                  _buildCwContent(cw, text),
                  const SizedBox(height: 8),
                ] else if (text != null) ...[
                  _mfmRenderer.processTextToRichText(
                    text,
                    context,
                    onEmojiLoaded: () {
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],

                // 附件内容
                if (note.files.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildMediaGrid(note.files),
                  ),

                // 投票卡片
                if (note.poll != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: PollCard(
                      noteId: note.id,
                      poll: note.poll!,
                      timelineType: widget.timelineType,
                    ),
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
                              } else if (note.myReaction != null) {
                                // 如果已经有其他表情反应，先取消再发送新的
                                await repository.removeReaction(note.id);
                                await repository.addReaction(note.id, reaction);
                              } else {
                                // 直接发送表情反应
                                await repository.addReaction(note.id, reaction);
                              }

                              // 重新获取笔记信息以更新状态
                              final updatedNote = await repository.getNote(
                                note.id,
                              );

                              // 更新缓存中的笔记
                              MisskeyTimelineNotifier.cacheManager.putNote(
                                updatedNote,
                              );

                              // 通知时间线状态管理更新
                              if (widget.timelineType != null) {
                                // 触发时间线刷新，确保UI立即更新
                                final timelineProvider =
                                    misskeyTimelineProvider(
                                      widget.timelineType!,
                                    );
                                ref.invalidate(timelineProvider);
                              }

                              // 移除成功提示，只在错误时显示提示
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
                                      behavior: SnackBarBehavior.floating,
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

                // 交互按钮行 (Twitter/X 左对齐风格)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAction(
                      Icons.reply,
                      note.repliesCount > 0 ? note.repliesCount.toString() : null,
                      _handleReply,
                      tooltip: 'Reply',
                    ),
                    const SizedBox(width: 4),
                    _buildAction(
                      Icons.repeat,
                      note.renoteCount > 0 ? note.renoteCount.toString() : null,
                      _handleRenote,
                      tooltip: 'Renote',
                    ),
                    const SizedBox(width: 4),
                    _buildAction(
                      Icons.favorite_border,
                      note.reactions.isNotEmpty ? note.reactions.length.toString() : null,
                      _handleReaction,
                      tooltip: 'Reaction',
                    ),
                    const SizedBox(width: 4),
                    _buildAction(
                      Icons.more_horiz,
                      null,
                      _showContextMenuFromButton,
                      tooltip: 'More',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Widget result = card;

    if (widget.isHighlighted) {
      final colorScheme = Theme.of(context).colorScheme;
      result = AnimatedContainer(
        duration: 600.ms,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: colorScheme.primary,
              width: 3,
            ),
          ),
          color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        ),
        child: result,
      );
    }

    return result;
  }

  void _showContextMenuFromButton() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = Offset(
      button.localToGlobal(Offset.zero).dx + button.size.width,
      button.localToGlobal(Offset.zero).dy + button.size.height / 2,
    );

    _showContextMenu(position);
  }

  OverlayEntry? _menuOverlayEntry;
  final GlobalKey _menuKey = GlobalKey();

  void _showContextMenu(Offset position) {
    _dismissMenu();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final menuColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final primaryColor = theme.colorScheme.primary;

    _menuOverlayEntry = OverlayEntry(
      builder: (context) => _FastPopupMenuOverlay(
        position: position,
        menuColor: menuColor,
        primaryColor: primaryColor,
        menuKey: _menuKey,
        onItemSelected: (value) {
          _dismissMenu();
          _handleMenuAction(value);
        },
        onDismissed: _dismissMenu,
      ),
    );

    Overlay.of(context).insert(_menuOverlayEntry!);
  }

  void _dismissMenu() {
    _menuOverlayEntry?.remove();
    _menuOverlayEntry = null;
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'details':
        _showDetails();
        break;
      case 'copy_content':
        if (widget.note.text != null) {
          Clipboard.setData(ClipboardData(text: widget.note.text!));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('post_copied'.tr()),
              behavior: SnackBarBehavior.floating,
            ),
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('post_id_copied'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('post_link_copied'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('post_bookmarked'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'post_bookmark_failed'.tr(namedArgs: {'error': e.toString()}),
            ),
            behavior: SnackBarBehavior.floating,
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
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
                      SnackBar(
                        content: Text('post_reported'.tr()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('post_report_failed'.tr()),
                      behavior: SnackBarBehavior.floating,
                    ),
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
    String? label,
    VoidCallback onTap, {
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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

  Widget _buildCwContent(String cw, String? text) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withAlpha(128),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.secondary.withAlpha(77),
            ),
          ),
          child: InkWell(
            onTap: () => setState(() => _isCwExpanded = !_isCwExpanded),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cw,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isCwExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withAlpha(128),
              ),
            ),
            child: text != null
                ? _mfmRenderer.processTextToRichText(
                    text,
                    context,
                    onEmojiLoaded: () {
                      if (mounted) setState(() {});
                    },
                  )
                : const SizedBox.shrink(),
          ),
          crossFadeState: _isCwExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topLeft,
        ),
      ],
    );
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
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repository = await ref.read(
                  misskeyRepositoryProvider.future,
                );
                await repository.renote(widget.note.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('note_renoted_successfully'.tr()),
                      behavior: SnackBarBehavior.floating,
                    ),
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
                      behavior: SnackBarBehavior.floating,
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
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repository = await ref.read(
                  misskeyRepositoryProvider.future,
                );
                await repository.reply(widget.note.id, textController.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('note_reply_sent'.tr()),
                      behavior: SnackBarBehavior.floating,
                    ),
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
                      behavior: SnackBarBehavior.floating,
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

              if (widget.note.myReaction != null) {
                // 如果已经有其他表情反应，先取消再发送新的
                await repository.removeReaction(widget.note.id);
              }
              await repository.addReaction(widget.note.id, emoji);
              // 移除成功提示，只在错误时显示提示
            } catch (e) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'note_failed_to_react'.tr(
                        namedArgs: {'error': e.toString()},
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('note_share_coming_soon'.tr()),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          logger.info(
            'ModernNoteCard: Tapped on reply preview for note ${widget.note.replyId}',
          );
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
                  if (replyNote.user != null)
                    CachedMisskeyAvatar(
                      userId: replyNote.user!.id,
                      avatarUrl: replyNote.user!.avatarUrl ?? '',
                      host: replyNote.user!.host,
                      radius: 8,
                      showIsMeBadge: false,
                    )
                  else
                    CircleAvatar(
                      radius: 8,
                      child: const Icon(Icons.person, size: 10),
                    ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      mainAxisSize: MainAxisSize.min,

                      children: [
                        _mfmRenderer.processTextToRichText(
                          replyNote.user?.name ??
                              replyNote.user?.username ??
                              'Unknown',
                          context,
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          onEmojiLoaded: () {
                            if (mounted) setState(() {});
                          },
                        ),
                        Text.rich(
                          TextSpan(
                            text: '@${replyNote.user?.username}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            children: replyNote.user?.host != null
                                ? [
                                    TextSpan(
                                      text: '@${replyNote.user!.host}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ]
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              _mfmRenderer.processTextToRichText(
                replyNote.text ?? replyNote.cw ?? '',
                context,
                onEmojiLoaded: () {
                  if (mounted) {
                    setState(() {});
                  }
                },
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textStyle: TextStyle(
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
            onTap: () => _openMediaViewer(
              context,
              widget.note.files,
              url,
            ),
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
            onTap: () => _openMediaViewer(
              context,
              widget.note.files,
              url,
              heroTag: heroTag,
            ),
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
          onTap: () => _openMediaViewer(
            context,
            widget.note.files,
            url,
          ),
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
          onTap: () => _openMediaViewer(
            context,
            widget.note.files,
            url,
            heroTag: heroTag,
          ),
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

  static void _openMediaViewer(
    BuildContext context,
    List<Map<String, dynamic>> allFiles,
    String targetUrl, {
    String? heroTag,
  }) {
    final mediaItems = <MediaItem>[];
    int initialIndex = 0;

    for (int i = 0; i < allFiles.length; i++) {
      final file = allFiles[i];
      final fileUrl = file['url'] as String?;
      final fileType = file['type'] as String? ?? '';
      if (fileUrl == null) continue;

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
        if (fileUrl == targetUrl) initialIndex = mediaItems.length - 1;
      } else if (isVideo) {
        mediaItems.add(
          MediaItem(
            url: fileUrl,
            type: MediaType.video,
            fileName: file['name'] as String?,
          ),
        );
        if (fileUrl == targetUrl) initialIndex = mediaItems.length - 1;
      } else if (isAudio) {
        mediaItems.add(
          MediaItem(
            url: fileUrl,
            type: MediaType.audio,
            fileName: file['name'] as String?,
          ),
        );
        if (fileUrl == targetUrl) initialIndex = mediaItems.length - 1;
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
  }
}

/// 快速弹出菜单覆盖层（使用 OverlayEntry 替代 PopupRoute）
class _FastPopupMenuOverlay extends StatefulWidget {
  final Offset position;
  final Color menuColor;
  final Color primaryColor;
  final GlobalKey menuKey;
  final void Function(String) onItemSelected;
  final VoidCallback onDismissed;

  const _FastPopupMenuOverlay({
    required this.position,
    required this.menuColor,
    required this.primaryColor,
    required this.menuKey,
    required this.onItemSelected,
    required this.onDismissed,
  });

  @override
  State<_FastPopupMenuOverlay> createState() => _FastPopupMenuOverlayState();
}

class _FastPopupMenuOverlayState extends State<_FastPopupMenuOverlay>
    with TickerProviderStateMixin {
  Offset _calculatedPosition = Offset.zero;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Rect? _menuBounds;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePosition();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculatePosition() {
    final renderBox = widget.menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final menuSize = renderBox.size;
      final screenSize = MediaQuery.of(context).size;
      var dx = widget.position.dx;
      var dy = widget.position.dy;

      if (dx + menuSize.width > screenSize.width) {
        dx = screenSize.width - menuSize.width - 8;
      }
      if (dy + menuSize.height > screenSize.height) {
        dy = screenSize.height - menuSize.height - 8;
      }
      if (dy < 0) dy = 8;

      setState(() {
        _calculatedPosition = Offset(dx, dy);
        _menuBounds = Rect.fromLTWH(dx, dy, menuSize.width, menuSize.height);
      });
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (_menuBounds != null && !_menuBounds!.contains(details.globalPosition)) {
      _dismiss();
    }
  }

  void _dismiss() async {
    await _animationController.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem(Icons.info_outline, 'post_menu_details'.tr(), 'details'),
      _MenuItem(Icons.copy, 'post_menu_copy_content'.tr(), 'copy_content'),
      _MenuItem(Icons.link, 'post_menu_copy_link'.tr(), 'copy_link'),
      _MenuItem(Icons.code, 'post_menu_embed'.tr(), null, enabled: false),
      _MenuItem(Icons.share, 'post_menu_share'.tr(), 'share'),
      _MenuItem(Icons.bookmark_border, 'post_menu_bookmark'.tr(), 'bookmark'),
      _MenuItem(Icons.reply, 'post_menu_add_note'.tr(), 'add_note'),
      _MenuItem(
        Icons.flag_outlined,
        'post_menu_report'.tr(),
        'report',
        iconColor: Colors.red,
        textColor: Colors.red,
      ),
      _MenuItem(Icons.copy_all, 'post_menu_copy_id'.tr(), 'copy_id'),
    ];

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _handleTapDown(TapDownDetails(globalPosition: event.position)),
      child: Stack(
        children: [
          Positioned(
            left: _calculatedPosition.dx,
            top: _calculatedPosition.dy,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                key: widget.menuKey,
                constraints: const BoxConstraints(maxWidth: 280, minWidth: 200),
                decoration: BoxDecoration(
                  color: widget.menuColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: _FastMenuItem(
                          icon: item.icon,
                          label: item.label,
                          enabled: item.enabled,
                          iconColor: item.iconColor ?? widget.primaryColor,
                          textColor: item.textColor,
                          onTap: () {
                            if (item.enabled && item.value != null) {
                              widget.onItemSelected(item.value!);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 快速菜单项
class _FastMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final Color iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _FastMenuItem({
    required this.icon,
    required this.label,
    this.enabled = true,
    this.iconColor = Colors.black87,
    this.textColor,
    required this.onTap,
  });

  @override
  State<_FastMenuItem> createState() => _FastMenuItemState();
}

class _FastMenuItemState extends State<_FastMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          borderRadius: BorderRadius.circular(10),
          hoverColor: widget.enabled
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _isHovered && widget.enabled
                  ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.enabled
                        ? (_isHovered ? theme.colorScheme.primary : widget.iconColor)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.enabled
                            ? (widget.textColor ?? theme.colorScheme.onSurface)
                            : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 菜单项数据模型
class _MenuItem {
  final IconData icon;
  final String label;
  final String? value;
  final bool enabled;
  final Color? iconColor;
  final Color? textColor;

  const _MenuItem(
    this.icon,
    this.label,
    this.value, {
    this.enabled = true,
    this.iconColor,
    this.textColor,
  });
}
