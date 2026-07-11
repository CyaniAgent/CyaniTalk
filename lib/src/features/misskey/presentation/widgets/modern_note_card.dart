import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/src/shared/widgets/toast_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '/src/core/utils/logger.dart';
import '/src/core/services/file_metadata_service.dart';
import '/src/features/misskey/domain/note.dart';
import '/src/features/misskey/domain/mfm_renderer.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/features/misskey/data/misskey_repository_interface.dart';
import '/src/features/misskey/presentation/widgets/poll_card.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import 'retryable_network_image.dart';
import 'cached_misskey_avatar.dart';
import 'mention_aware_text.dart';
import '/src/features/common/presentation/pages/media_viewer_page.dart';

import '/src/features/common/presentation/widgets/media/media_item.dart';
import '/src/features/common/presentation/widgets/media/audio_player_sheet.dart';
import 'emoji_picker.dart';
import 'reaction_display.dart';
import 'note_details_sheet.dart';

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

    _mfmRenderer.mentionTap = (userName, host, acct) async {
      try {
        final repository = await ref.read(misskeyRepositoryProvider.future);
        final user = await repository.findUserByUsername(
          userName,
          host: host,
        );
        if (mounted) {
          context.push('/misskey/user/${user.id}', extra: user);
        }
      } catch (e) {
        logger.debug('Mention tap: could not find user $acct');
        if (mounted) {
          showToast(title: 'User not found: $acct', type: ToastificationType.info);
        }
      }
    };
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
                  MentionAwareText(
                    text: text,
                    mfmRenderer: _mfmRenderer,
                    onEmojiLoaded: () {
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    onMentionTap: (userId) {
                      if (mounted) context.push('/misskey/user/$userId');
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
                                  showToast(
                                    title: 'note_failed_to_react'.tr(
                                      namedArgs: {'error': e.toString()},
                                    ),
                                    type: ToastificationType.error,
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
    final menuColor = theme.colorScheme.surface;
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
          showToast(title: 'post_copied'.tr(), type: ToastificationType.success);
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
        showToast(title: 'post_id_copied'.tr(), type: ToastificationType.success);
        break;
    }
  }

  void _showDetails() {
    NoteDetailsSheet.show(context, widget.note);
  }

  Future<void> _copyLink() async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final host = repository.host;
      final url = 'https://$host/notes/${widget.note.id}';
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        showToast(title: 'post_link_copied'.tr(), type: ToastificationType.success);
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
        showToast(title: 'post_bookmarked'.tr(), type: ToastificationType.success);
      }
    } catch (e) {
      if (mounted) {
        showToast(
          title: 'post_bookmark_failed'.tr(namedArgs: {'error': e.toString()}),
          type: ToastificationType.error,
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
                    showToast(title: 'post_reported'.tr(), type: ToastificationType.success);
                  }
                }
              } catch (e) {
                if (mounted) {
                  showToast(title: 'post_report_failed'.tr(), type: ToastificationType.error);
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
                ? MentionAwareText(
                    text: text,
                    mfmRenderer: _mfmRenderer,
                    onEmojiLoaded: () {
                      if (mounted) setState(() {});
                    },
                    onMentionTap: (userId) {
                      if (mounted) context.push('/misskey/user/$userId');
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
        title: const Text('转发确认'),
        content: const Text('确定要转发这条消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
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
                  showToast(title: 'note_renoted_successfully'.tr(), type: ToastificationType.success);
                }
              } catch (e) {
                if (mounted) {
                  showToast(
                    title: 'note_failed_to_renote'.tr(
                      namedArgs: {'error': e.toString()},
                    ),
                    type: ToastificationType.error,
                  );
                }
              }
            },
            child: const Text('确定'),
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
                  showToast(title: 'note_reply_sent'.tr(), type: ToastificationType.success);
                }
              } catch (e) {
                if (mounted) {
                  showToast(
                    title: 'note_failed_to_reply'.tr(
                      namedArgs: {'error': e.toString()},
                    ),
                    type: ToastificationType.error,
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
                showToast(
                  title: 'note_failed_to_react'.tr(
                    namedArgs: {'error': e.toString()},
                  ),
                  type: ToastificationType.error,
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
    showToast(title: 'note_share_coming_soon'.tr(), type: ToastificationType.info);
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
                    const CircleAvatar(
                      radius: 8,
                      child: Icon(Icons.person, size: 10),
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

  /// 构建媒体网格 - 新布局系统
  Widget _buildMediaGrid(List<Map<String, dynamic>> files) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    // 分类文件
    final imageFiles = <Map<String, dynamic>>[];
    final videoFiles = <Map<String, dynamic>>[];
    final audioFiles = <Map<String, dynamic>>[];
    final otherFiles = <Map<String, dynamic>>[];

    for (final file in files) {
      final url = file['url'] as String?;
      final type = file['type'] as String?;
      if (url == null) continue;

      if (_isImageFile(type, url)) {
        imageFiles.add(file);
      } else if (_isVideoFile(type, url)) {
        videoFiles.add(file);
      } else if (_isAudioFile(type, url)) {
        audioFiles.add(file);
      } else {
        otherFiles.add(file);
      }
    }

    if (imageFiles.isEmpty && videoFiles.isEmpty && audioFiles.isEmpty && otherFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片区
        if (imageFiles.isNotEmpty) ...[
          if (isDesktop)
            _buildDesktopImageGrid(imageFiles)
          else
            _buildMobileImageGrid(imageFiles),
        ],

        // 视频区
        if (videoFiles.isNotEmpty) ...[
          if (imageFiles.isNotEmpty) const SizedBox(height: 8),
          ...videoFiles.map(_buildVideoItem),
        ],

        // 音频区
        if (audioFiles.isNotEmpty) ...[
          if (imageFiles.isNotEmpty || videoFiles.isNotEmpty) const SizedBox(height: 8),
          _buildAudioGrid(audioFiles),
        ],

        // 其他文件区
        if (otherFiles.isNotEmpty) ...[
          if (imageFiles.isNotEmpty || videoFiles.isNotEmpty || audioFiles.isNotEmpty)
            const SizedBox(height: 8),
          _buildOtherFilesButton(otherFiles),
        ],
      ],
    );
  }

  /// 移动端图片网格布局
  Widget _buildMobileImageGrid(List<Map<String, dynamic>> images) {
    if (images.length == 1) {
      return _buildImageThumbnail(images[0], height: 200);
    } else if (images.length == 2) {
      return SizedBox(
        height: 120,
        child: Row(
          children: [
            Expanded(child: _buildImageThumbnail(images[0], height: 120)),
            const SizedBox(width: 4),
            Expanded(child: _buildImageThumbnail(images[1], height: 120)),
          ],
        ),
      );
    } else if (images.length == 3) {
      return Column(
        children: [
          _buildImageThumbnail(images[0], height: 140),
          const SizedBox(height: 4),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(child: _buildImageThumbnail(images[1], height: 100)),
                const SizedBox(width: 4),
                Expanded(child: _buildImageThumbnail(images[2], height: 100)),
              ],
            ),
          ),
        ],
      );
    } else if (images.length == 4) {
      return SizedBox(
        height: 204,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImageThumbnail(images[0])),
                  const SizedBox(width: 4),
                  Expanded(child: _buildImageThumbnail(images[1])),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImageThumbnail(images[2])),
                  const SizedBox(width: 4),
                  Expanded(child: _buildImageThumbnail(images[3])),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // 5+ 张图片，2列网格
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) => _buildImageThumbnail(images[index]),
      );
    }
  }

  /// 桌面端图片网格布局 - 顺序排列 + 左右导航
  Widget _buildDesktopImageGrid(List<Map<String, dynamic>> images) {
    if (images.length <= 9) {
      // 少于等于9张，直接3列网格
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) => _buildImageThumbnail(images[index]),
      );
    } else {
      // 超过9张，使用分页导航
      return _DesktopImageGridWithNav(images: images);
    }
  }

  /// 单个图片缩略图
  Widget _buildImageThumbnail(Map<String, dynamic> file, {double? height}) {
    final url = file['url'] as String?;
    if (url == null) return const SizedBox.shrink();

    final heroTag = 'image_${url}_${widget.note.id}';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        onTap: () => _openMediaViewer(context, widget.note.files, url, heroTag: heroTag),
        child: Hero(
          tag: heroTag,
          child: SizedBox(
            height: height,
            child: RetryableNetworkImage(
              url: file['thumbnailUrl'] as String? ?? url,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  /// 视频项 - 1行1个，缩略图为视频第一帧
  Widget _buildVideoItem(Map<String, dynamic> file) {
    final url = file['url'] as String?;
    final thumbnailUrl = file['thumbnailUrl'] as String? ?? url;
    if (url == null || thumbnailUrl == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _openMediaViewer(context, widget.note.files, url),
          child: Stack(
            alignment: Alignment.center,
            children: [
              RetryableNetworkImage(
                url: thumbnailUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 音频网格 - 1行2个
  Widget _buildAudioGrid(List<Map<String, dynamic>> audioFiles) {
    final rows = <Widget>[];
    for (var i = 0; i < audioFiles.length; i += 2) {
      final rowChildren = <Widget>[
        Expanded(child: _buildAudioItem(audioFiles[i])),
      ];
      if (i + 1 < audioFiles.length) {
        rowChildren.add(const SizedBox(width: 8));
        rowChildren.add(Expanded(child: _buildAudioItem(audioFiles[i + 1])));
      } else {
        rowChildren.add(const Spacer());
      }
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: rowChildren),
      ));
    }
    return Column(children: rows);
  }

  /// 单个音频项
  Widget _buildAudioItem(Map<String, dynamic> file) {
    final url = file['url'] as String?;
    final name = file['name'] as String? ?? 'Unknown';
    final fileId = file['id'] as String?;
    final fileSize = file['size'] as int?;

    if (url == null) return const SizedBox.shrink();

    return _AudioItemWidget(
      url: url,
      name: name,
      fileId: fileId,
      fileSize: fileSize,
      onTap: () => _openMediaViewer(context, widget.note.files, url),
    );
  }

  /// 其他文件按钮
  Widget _buildOtherFilesButton(List<Map<String, dynamic>> otherFiles) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showOtherFilesDialog(otherFiles),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.insert_drive_file,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              '其它文件 ${otherFiles.length}个',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示其他文件对话框
  void _showOtherFilesDialog(List<Map<String, dynamic>> otherFiles) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _OtherFilesDialog(otherFiles: otherFiles),
    );
  }

  static void _openMediaViewer(
    BuildContext context,
    List<Map<String, dynamic>> allFiles,
    String targetUrl, {
    String? heroTag,
  }) {
    // 查找目标文件
    final targetFile = allFiles.firstWhere(
      (file) => file['url'] == targetUrl,
      orElse: () => {},
    );
    final targetType = targetFile['type'] as String? ?? '';

    // 如果是音频文件，使用统一的音频播放器
    if (targetType.startsWith('audio/')) {
      showAudioPlayerSheet(
        context,
        mediaItem: MediaItem(
          url: targetUrl,
          type: MediaType.audio,
          fileName: targetFile['name'] as String?,
        ),
      );
      return;
    }

    // 其他文件类型使用媒体查看器
    final mediaItems = <MediaItem>[];
    int initialIndex = 0;

    for (int i = 0; i < allFiles.length; i++) {
      final file = allFiles[i];
      final fileUrl = file['url'] as String?;
      final fileType = file['type'] as String? ?? '';
      if (fileUrl == null) continue;

      final isImage = fileType.startsWith('image/');
      final isVideo = fileType.startsWith('video/');

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

/// 桌面端图片网格 - 带分页导航
class _DesktopImageGridWithNav extends StatefulWidget {
  final List<Map<String, dynamic>> images;

  const _DesktopImageGridWithNav({required this.images});

  @override
  State<_DesktopImageGridWithNav> createState() => _DesktopImageGridWithNavState();
}

class _DesktopImageGridWithNavState extends State<_DesktopImageGridWithNav> {
  int _currentPage = 0;
  static const int _itemsPerPage = 9;

  int get _totalPages => (widget.images.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, widget.images.length);
    final currentImages = widget.images.sublist(startIndex, endIndex);

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: currentImages.length,
          itemBuilder: (context, index) {
            final file = currentImages[index];
            final url = file['url'] as String?;
            if (url == null) return const SizedBox.shrink();

            final heroTag = 'image_${url}_desktop_$index';
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MediaViewerPage(
                        mediaItems: widget.images
                            .where((f) => f['url'] != null)
                            .map((f) => MediaItem(
                                  url: f['url'] as String,
                                  type: MediaType.image,
                                  fileName: f['name'] as String?,
                                ))
                            .toList(),
                        initialIndex: startIndex + index,
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: heroTag,
                  child: RetryableNetworkImage(
                    url: file['thumbnailUrl'] as String? ?? url,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
        if (_totalPages > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentPage < _totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ],
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

/// 音频项组件（带时长获取）
class _AudioItemWidget extends StatefulWidget {
  final String url;
  final String name;
  final String? fileId;
  final int? fileSize;
  final VoidCallback onTap;

  const _AudioItemWidget({
    required this.url,
    required this.name,
    this.fileId,
    this.fileSize,
    required this.onTap,
  });

  @override
  State<_AudioItemWidget> createState() => _AudioItemWidgetState();
}

class _AudioItemWidgetState extends State<_AudioItemWidget> {
  int? _durationMs;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDuration();
  }

  Future<void> _loadDuration() async {
    if (widget.fileId == null) {
      setState(() {
        _isLoading = false;
        _error = 'no_file_id';
      });
      return;
    }

    try {
      final metadataService = FileMetadataService();
      final duration = await metadataService.getAudioDuration(
        widget.fileId!,
        widget.url,
      );
      
      if (mounted) {
        setState(() {
          _durationMs = duration;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.audiotrack,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoText(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(ThemeData theme) {
    final sizeText = FileMetadataService.formatFileSize(widget.fileSize);
    
    if (_isLoading) {
      // 显示文件大小 · 计算中...
      return Text(
        '$sizeText · ${'audio_calculating'.tr()}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (_error != null || _durationMs == null) {
      // 仅显示文件大小
      return Text(
        sizeText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    // 显示文件大小 · 音频时长
    final durationText = FileMetadataService.formatDuration(_durationMs);
    return Text(
      '$sizeText · $durationText',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// 其他文件对话框
class _OtherFilesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> otherFiles;

  const _OtherFilesDialog({required this.otherFiles});

  @override
  State<_OtherFilesDialog> createState() => _OtherFilesDialogState();
}

class _OtherFilesDialogState extends State<_OtherFilesDialog> {
  final Map<int, int?> _fileSizes = {};
  final Map<int, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadAllFileSizes();
  }

  Future<void> _loadAllFileSizes() async {
    final metadataService = FileMetadataService();
    
    for (int i = 0; i < widget.otherFiles.length; i++) {
      final file = widget.otherFiles[i];
      final fileId = file['id'] as String?;
      final fileUrl = file['url'] as String?;
      final existingSize = file['size'] as int?;
      
      // 如果已有大小且大于0，直接使用
      if (existingSize != null && existingSize > 0) {
        setState(() {
          _fileSizes[i] = existingSize;
        });
        continue;
      }
      
      // 否则从网络获取
      if (fileId != null && fileUrl != null) {
        setState(() {
          _loadingStates[i] = true;
        });
        
        final size = await metadataService.getFileSize(fileId, fileUrl);
        
        if (mounted) {
          setState(() {
            _fileSizes[i] = size;
            _loadingStates[i] = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '其它文件',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.otherFiles.length,
              itemBuilder: (context, index) {
                final file = widget.otherFiles[index];
                final name = file['name'] as String? ?? 'Unknown';
                final type = file['type'] as String? ?? '';
                final size = _fileSizes[index];
                final isLoading = _loadingStates[index] ?? false;
                
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(_buildSubtitle(type, size, isLoading)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(String type, int? size, bool isLoading) {
    if (isLoading) {
      return '$type - ${'file_calculating_size'.tr()}';
    }
    
    final sizeText = FileMetadataService.formatFileSize(size);
    return '$type - $sizeText';
  }
}
