import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/note.dart';
import '../../data/misskey_repository.dart';
import 'retryable_network_image.dart';
import 'audio_player_widget.dart';
import '../pages/image_viewer_page.dart';
import '../pages/video_player_page.dart';

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

  // 缓存文本处理结果，避免重复计算
  final Map<String, List<TextSpan>> _textProcessingCache = {};

  /// 处理文本中的特殊格式
  /// 
  /// 处理文本中的加粗文本(**text**)、提及(@username)和话题(#hashtag)，
  /// 并返回对应的TextSpan列表。会缓存处理结果，避免重复计算。
  List<TextSpan> _processText(String text) {
    // 检查是否已缓存处理结果
    if (_textProcessingCache.containsKey(text)) {
      return _textProcessingCache[text]!;
    }

    final List<TextSpan> spans = [];
    int currentIndex = 0;

    // 处理加粗文本 (**text**)
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final mentionRegex = RegExp(r'@([a-zA-Z0-9_]+)');
    final hashtagRegex = RegExp(r'#([^\s]+)');

    // 收集所有匹配项并按位置排序
    final List<RegExpMatch> allMatches = [];
    allMatches.addAll(boldRegex.allMatches(text));
    allMatches.addAll(mentionRegex.allMatches(text));
    allMatches.addAll(hashtagRegex.allMatches(text));

    // 按匹配位置排序
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in allMatches) {
      // 添加匹配前的文本
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      // 检查是哪种匹配
      if (boldRegex.hasMatch(text.substring(match.start, match.end))) {
        // 加粗文本
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (mentionRegex.hasMatch(
        text.substring(match.start, match.end),
      )) {
        // 提及用户
        spans.add(
          TextSpan(
            text: text.substring(match.start, match.end),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            recognizer: null, // 可以添加TapGestureRecognizer来处理点击
          ),
        );
      } else if (hashtagRegex.hasMatch(
        text.substring(match.start, match.end),
      )) {
        // 话题
        spans.add(
          TextSpan(
            text: text.substring(match.start, match.end),
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            recognizer: null, // 可以添加TapGestureRecognizer来处理点击
          ),
        );
      }

      currentIndex = match.end;
    }

    // 处理剩余文本
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    // 缓存处理结果
    _textProcessingCache[text] = spans;
    
    // 限制缓存大小，避免内存泄漏
    if (_textProcessingCache.length > 50) {
      // 移除最早的缓存项
      final firstKey = _textProcessingCache.keys.first;
      _textProcessingCache.remove(firstKey);
    }

    return spans;
  }

  @override
  void initState() {
    super.initState();
    // Only animate if the note is new (created within the last 15 seconds)
    // This prevents animation on old posts when scrolling, which can cause
    // issues with AudioPlayer state and "Bad Element" errors.
    final diff = DateTime.now()
        .difference(widget.note.createdAt)
        .inSeconds
        .abs();
    _shouldAnimate = diff < 15;
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
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Semantics(
                      label: 'Attached files',
                      child: Column(
                        children: note.files.map((file) {
                          final url = file['url'] as String?;
                          final type = file['type'] as String?;
                          final name = file['name'] as String?;

                          if (url == null) {
                            return const SizedBox.shrink();
                          }

                          // Detect media type
                          final isImage = _isImageFile(type, url);
                          final isVideo = _isVideoFile(type, url);
                          final isAudio = _isAudioFile(type, url);

                          if (isAudio) {
                            // Audio player
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: AudioPlayerWidget(
                                audioUrl: url,
                                fileName: name,
                              ),
                            );
                          } else if (isVideo) {
                            // Video thumbnail
                            final thumbnailUrl =
                                file['thumbnailUrl'] as String? ?? url;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VideoPlayerPage(videoUrl: url),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      RetryableNetworkImage(
                                        url: thumbnailUrl,
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
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
                            // Image thumbnail
                            final thumbnailUrl =
                                file['thumbnailUrl'] as String? ?? url;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ImageViewerPage(
                                          imageUrl: url,
                                          heroTag: 'image_$url',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'image_$url',
                                    child: RetryableNetworkImage(
                                      url: thumbnailUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        }).toList(),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      label: 'Reply button',
                      child: _buildAction(
                        Icons.reply,
                        note.repliesCount.toString(),
                        _handleReply,
                      ),
                    ),
                    Semantics(
                      label: 'Renote button',
                      child: _buildAction(
                        Icons.repeat,
                        note.renoteCount.toString(),
                        _handleRenote,
                      ),
                    ),
                    Semantics(
                      label: 'Reaction button',
                      child: _buildAction(
                        Icons.add_reaction_outlined,
                        note.reactions.length.toString(),
                        _handleReaction,
                      ),
                    ),
                    Semantics(
                      label: 'Share button',
                      child: _buildAction(
                        Icons.share_outlined,
                        "",
                        _handleShare,
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
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
    }

    return card;
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
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
                final repository = await ref.read(misskeyRepositoryProvider.future);
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
    try {
      // Default to heart for now
      final repository = await ref.read(misskeyRepositoryProvider.future);
      await repository.addReaction(widget.note.id, '❤️');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('note_reaction_added'.tr())));
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
}
