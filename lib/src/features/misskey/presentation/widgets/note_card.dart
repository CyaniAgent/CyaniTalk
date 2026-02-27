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
import 'retryable_network_image.dart';
import 'audio_player_widget.dart';
import '../../../common/presentation/pages/media_viewer_page.dart';
import 'emoji_picker.dart';
import 'reaction_display.dart';

import '../../../common/presentation/widgets/media/media_item.dart';

/// NoteCard组件
///
/// 用于显示单个Misskey笔记的卡片组件，支持显示用户信息、文本内容、媒体文件和互动按钮。
///
/// @param note 要显示的笔记对象
class NoteCard extends ConsumerStatefulWidget {
  final Note note;

  /// 创建NoteCard组件
  ///
  /// @param key 组件的键
  /// @param note 要显示的笔记对象
  const NoteCard({super.key, required this.note});

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
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
  List<TextSpan> _processText(String text) {
    return _mfmRenderer.processText(text, context);
  }

  @override
  void initState() {
    super.initState();
    _shouldAnimate = false;
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final user = note.user;
    final text = note.text;
    final cw = note.cw;

    Widget card = RepaintBoundary(
      child: Semantics(
        label: 'Note by ${user?.username}',
        value: text ?? cw,
        child: GestureDetector(
          onSecondaryTapDown: (details) =>
              _showContextMenu(details.globalPosition),
          onLongPressStart: (details) =>
              _showContextMenu(details.globalPosition),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (user?.id != null) {
                        final me = ref.read(misskeyMeProvider).value;
                        if (me != null && me.id == user!.id) {
                          // Redirect to own profile tab
                          context.go('/profile');
                        } else {
                          context.push(
                            '/misskey/user/${user!.id}',
                            extra: user,
                          );
                        }
                      }
                    },
                    child: Row(
                      children: [
                        Semantics(
                          label: 'Avatar for ${user?.username}',
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null,
                            child: user?.avatarUrl == null
                                ? Text(user?.username[0].toUpperCase() ?? '?')
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                label: 'User name',
                                child: Text(
                                  user?.name ?? user?.username ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Semantics(
                                label: 'User handle',
                                child: Text(
                                  '@${user?.username}${user?.host != null ? "@${user!.host}" : ""}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Semantics(
                          label: 'Post time',
                          child: Text(
                            _formatTime(note.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (cw != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                  ] else if (text != null)
                    SelectableText.rich(TextSpan(children: _processText(text))),

                  if (note.files.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Semantics(
                        label: 'Attached files',
                        child: _buildMediaGrid(note.files),
                      ),
                    ),

                  if (note.reactions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: FutureBuilder<IMisskeyRepository>(
                        future: ref.read(misskeyRepositoryProvider.future),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final repository = snapshot.data!;
                            return ReactionDisplay(
                              note: note,
                              host: repository.host,
                              onReactionTap: _handleReactionTap,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Semantics(
                          label: 'Reply button',
                          child: _buildAction(
                            Icons.reply,
                            note.repliesCount.toString(),
                            _handleReply,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Semantics(
                          label: 'Renote button',
                          child: _buildAction(
                            Icons.repeat,
                            note.renoteCount.toString(),
                            _handleRenote,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Semantics(
                          label: 'Reaction button',
                          child: _buildAction(
                            Icons.add_reaction_outlined,
                            note.reactions.length.toString(),
                            _handleReaction,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Semantics(
                          label: 'Share button',
                          child: _buildAction(
                            Icons.share_outlined,
                            "",
                            _handleShare,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (_shouldAnimate) {
      return card
          .animate(
            onComplete: (controller) {
              if (mounted)
                setState(() {
                  _shouldAnimate = false;
                });
            },
          )
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
    }

    return card;
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

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
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
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
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
              'note_failed_to_renote'.tr(namedArgs: {'error': e.toString()}),
            ),
          ),
        );
      }
    }
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
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return EmojiPicker(
          noteId: widget.note.id,
          currentReaction: widget.note.myReaction,
          onEmojiSelected: (emoji) async {
            try {
              final repository = await ref.read(
                misskeyRepositoryProvider.future,
              );
              await repository.addReaction(widget.note.id, emoji);
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
          onReactionRemoved: () async {
            try {
              final repository = await ref.read(
                misskeyRepositoryProvider.future,
              );
              await repository.removeReaction(widget.note.id);
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('note_reaction_removed'.tr())),
                );
              }
            } catch (e) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'note_failed_to_remove_reaction'.tr(
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

  Future<void> _handleReactionTap(String reaction) async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);

      // 检查是否是取消自己的表情反应
      if (widget.note.myReaction == reaction) {
        await repository.removeReaction(widget.note.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('note_reaction_removed'.tr())));
        }
      } else if (widget.note.myReaction != null) {
        // 如果已经有其他表情反应，先取消再发送新的
        await repository.removeReaction(widget.note.id);
        await repository.addReaction(widget.note.id, reaction);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('note_reaction_updated'.tr())));
        }
      } else {
        // 直接发送表情反应
        await repository.addReaction(widget.note.id, reaction);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('note_reaction_added'.tr())));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'note_failed_to_react'.tr(namedArgs: {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }

  void _handleShare() {
    // Placeholder for share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('note_share_coming_soon'.tr())));
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
          borderRadius: BorderRadius.circular(12),
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
    } else if (isImage) {
      final heroTag = 'image_${url}_${widget.note.id}';
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
    return Column(
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
        borderRadius: BorderRadius.circular(12),
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
                mediaItems.add(MediaItem(url: fileUrl, type: MediaType.audio));
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
        borderRadius: BorderRadius.circular(12),
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
                mediaItems.add(MediaItem(url: fileUrl, type: MediaType.audio));
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
