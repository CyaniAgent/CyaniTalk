import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/src/features/misskey/domain/note.dart';
import '/src/features/misskey/domain/mfm_renderer.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/shared/widgets/circle_icon_button.dart';
import 'cached_misskey_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class NoteDetailsSheet extends StatelessWidget {
  final Note note;
  final String? replyAuthorName;
  final String? replyAuthorUsername;

  const NoteDetailsSheet({
    super.key,
    required this.note,
    this.replyAuthorName,
    this.replyAuthorUsername,
  });

  static void show(BuildContext context, Note note, {String? replyAuthorName, String? replyAuthorUsername}) {
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    if (isWideScreen) {
      showSideSheet(context, note, replyAuthorName: replyAuthorName, replyAuthorUsername: replyAuthorUsername);
    } else {
      showBottomSheet(context, note, replyAuthorName: replyAuthorName, replyAuthorUsername: replyAuthorUsername);
    }
  }

  static void showBottomSheet(BuildContext context, Note note, {String? replyAuthorName, String? replyAuthorUsername}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _NoteDetailsContent(
          note: note,
          scrollController: scrollController,
          replyAuthorName: replyAuthorName,
          replyAuthorUsername: replyAuthorUsername,
        ),
      ),
    );
  }

  static void showSideSheet(BuildContext context, Note note, {String? replyAuthorName, String? replyAuthorUsername}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 8,
            child: SizedBox(
              width: 420,
              height: double.infinity,
              child: _NoteDetailsContent(
                note: note,
                replyAuthorName: replyAuthorName,
                replyAuthorUsername: replyAuthorUsername,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _NoteDetailsContent(note: note);
  }
}

class _NoteDetailsContent extends ConsumerStatefulWidget {
  final Note note;
  final ScrollController? scrollController;
  final String? replyAuthorName;
  final String? replyAuthorUsername;

  const _NoteDetailsContent({
    required this.note,
    this.scrollController,
    this.replyAuthorName,
    this.replyAuthorUsername,
  });

  @override
  ConsumerState<_NoteDetailsContent> createState() => _NoteDetailsContentState();
}

class _NoteDetailsContentState extends ConsumerState<_NoteDetailsContent> {
  late final MfmRenderer _mfmRenderer;
  bool _showRawData = false;

  @override
  void initState() {
    super.initState();
    _mfmRenderer = MfmRenderer();
    _initMfmRenderer();
  }

  void _initMfmRenderer() {
    _mfmRenderer.setApiEmojiLoader((emojiName) async {
      try {
        final repository = await ref.read(misskeyRepositoryProvider.future);
        final emojiDetail = await repository.getEmoji(emojiName);
        return emojiDetail.url;
      } catch (e) {
        return null;
      }
    });
  }

  @override
  void dispose() {
    _mfmRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteTimestamp = _parseSnowflakeTimestamp(widget.note.id);
    final isReply = widget.note.replyId != null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'post_details'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CircleIconButton(
                  icon: Icons.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                _buildSection(
                  context,
                  title: isReply ? 'note_detail_reply_author'.tr() : 'note_detail_author'.tr(),
                  icon: Icons.person_outline,
                  child: _buildUserInfo(context),
                ),
                const SizedBox(height: 20),

                if (isReply && widget.replyAuthorName != null) ...[
                  _buildSection(
                    context,
                    title: 'note_detail_original_author'.tr(),
                    icon: Icons.person_outline,
                    child: _buildOriginalAuthorInfo(context),
                  ),
                  const SizedBox(height: 20),
                ],

                _buildSection(
                  context,
                  title: 'note_detail_post_info'.tr(),
                  icon: Icons.article_outlined,
                  child: _buildPostInfo(context, noteTimestamp),
                ),
                const SizedBox(height: 20),

                if (widget.note.text != null && widget.note.text!.isNotEmpty) ...[
                  _buildSection(
                    context,
                    title: 'note_detail_content'.tr(),
                    icon: Icons.text_fields,
                    child: _buildContentPreview(context),
                  ),
                  const SizedBox(height: 20),
                ],

                if (widget.note.reactions.isNotEmpty) ...[
                  _buildSection(
                    context,
                    title: 'note_detail_reactions'.tr(),
                    icon: Icons.emoji_emotions_outlined,
                    child: _buildReactions(context),
                  ),
                  const SizedBox(height: 20),
                ],

                _buildSection(
                  context,
                  title: 'note_detail_statistics'.tr(),
                  icon: Icons.bar_chart_outlined,
                  child: _buildStatistics(context),
                ),
                const SizedBox(height: 20),

                _buildSection(
                  context,
                  title: 'note_detail_visibility'.tr(),
                  icon: Icons.visibility_outlined,
                  child: _buildVisibilityFlags(context),
                ),
                const SizedBox(height: 20),

                _buildSection(
                  context,
                  title: 'note_detail_technical'.tr(),
                  icon: Icons.code,
                  child: _buildTechnicalDetails(context, noteTimestamp),
                ),
                const SizedBox(height: 20),

                _buildRawDataButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.note.user;

    return Row(
      children: [
        if (user != null) ...[
          GestureDetector(
            onTap: () {
              context.push('/misskey/user/${user.id}', extra: user);
            },
            child: CachedMisskeyAvatar(
              userId: user.id,
              avatarUrl: user.avatarUrl ?? '',
              host: user.host,
              radius: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.push('/misskey/user/${user.id}', extra: user);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? user.username,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${user.username}${user.host != null ? '@${user.host}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOriginalAuthorInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.person_outline, size: 24, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.replyAuthorName ?? 'unknown',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '@${widget.replyAuthorUsername ?? 'unknown'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostInfo(BuildContext context, DateTime? noteTimestamp) {
    final createdAt = widget.note.createdAt;
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

    return Column(
      children: [
        _buildInfoRow(
          context,
          label: 'note_detail_id'.tr(),
          value: widget.note.id,
          onTap: () {
            Clipboard.setData(ClipboardData(text: widget.note.id));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('post_id_copied'.tr())),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          label: 'note_detail_created'.tr(),
          value: formattedDate,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          label: 'note_detail_timeago'.tr(),
          value: timeago.format(createdAt, locale: 'zh'),
        ),
      ],
    );
  }

  Widget _buildContentPreview(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _mfmRenderer.processTextToRichText(
        widget.note.text!,
        context,
        textStyle: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildReactions(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.note.reactions.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withAlpha(100),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                entry.value.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          icon: Icons.repeat,
          label: 'note_detail_renotes'.tr(),
          value: widget.note.renoteCount,
        ),
        _buildStatItem(
          context,
          icon: Icons.reply,
          label: 'note_detail_replies'.tr(),
          value: widget.note.repliesCount,
        ),
        _buildStatItem(
          context,
          icon: Icons.emoji_emotions,
          label: 'note_detail_reactions'.tr(),
          value: widget.note.reactions.values.fold(0, (sum, count) => sum + count),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityFlags(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildFlagRow(
          context,
          label: 'note_detail_visibility'.tr(),
          value: _getVisibilityLabel(widget.note.visibility),
          icon: _getVisibilityIcon(widget.note.visibility),
          color: _getVisibilityColor(widget.note.visibility, theme),
        ),
        const SizedBox(height: 8),
        _buildFlagRow(
          context,
          label: 'note_detail_local_only'.tr(),
          value: widget.note.localOnly ? 'common_yes'.tr() : 'common_no'.tr(),
          icon: widget.note.localOnly ? Icons.check_circle : Icons.cancel,
          color: widget.note.localOnly ? Colors.orange : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        _buildFlagRow(
          context,
          label: 'note_detail_has_poll'.tr(),
          value: widget.note.poll != null ? 'common_yes'.tr() : 'common_no'.tr(),
          icon: widget.note.poll != null ? Icons.check_circle : Icons.cancel,
          color: widget.note.poll != null ? Colors.blue : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        _buildFlagRow(
          context,
          label: 'note_detail_has_cw'.tr(),
          value: widget.note.cw != null ? 'common_yes'.tr() : 'common_no'.tr(),
          icon: widget.note.cw != null ? Icons.check_circle : Icons.cancel,
          color: widget.note.cw != null ? Colors.purple : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        _buildFlagRow(
          context,
          label: 'note_detail_has_files'.tr(),
          value: widget.note.fileIds.isNotEmpty ? 'common_yes'.tr() : 'common_no'.tr(),
          icon: widget.note.fileIds.isNotEmpty ? Icons.check_circle : Icons.cancel,
          color: widget.note.fileIds.isNotEmpty ? Colors.green : theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildFlagRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalDetails(BuildContext context, DateTime? noteTimestamp) {
    return Column(
      children: [
        _buildInfoRow(
          context,
          label: 'note_detail_uri'.tr(),
          value: widget.note.user?.host != null
              ? 'https://${widget.note.user!.host}/notes/${widget.note.id}'
              : 'note_detail_local'.tr(),
          onTap: widget.note.user?.host != null
              ? () {
                  Clipboard.setData(
                    ClipboardData(text: 'https://${widget.note.user!.host}/notes/${widget.note.id}'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('post_link_copied'.tr())),
                  );
                }
              : null,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          label: 'note_detail_user_id'.tr(),
          value: widget.note.userId ?? 'unknown',
          onTap: widget.note.userId != null
              ? () {
                  Clipboard.setData(ClipboardData(text: widget.note.userId!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('post_id_copied'.tr())),
                  );
                }
              : null,
        ),
        if (widget.note.replyId != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            label: 'note_detail_reply_to'.tr(),
            value: widget.note.replyId!,
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.note.replyId!));
            },
          ),
        ],
        if (widget.note.renoteId != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            label: 'note_detail_renote_of'.tr(),
            value: widget.note.renoteId!,
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.note.renoteId!));
            },
          ),
        ],
        if (widget.note.fileIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            label: 'note_detail_files'.tr(),
            value: '${widget.note.fileIds.length} ${'note_detail_files_count'.tr()}',
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onTap != null ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.copy,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }

  DateTime? _parseSnowflakeTimestamp(String noteId) {
    try {
      final id = int.parse(noteId);
      final timestampMs = id >> 22;
      return DateTime.fromMillisecondsSinceEpoch(timestampMs);
    } catch (e) {
      return null;
    }
  }

  String _getVisibilityLabel(String? visibility) {
    switch (visibility) {
      case 'public':
        return 'note_visibility_public'.tr();
      case 'home':
        return 'note_visibility_home'.tr();
      case 'followers':
        return 'note_visibility_followers'.tr();
      case 'specified':
        return 'note_visibility_specified'.tr();
      default:
        return visibility ?? 'unknown';
    }
  }

  IconData _getVisibilityIcon(String? visibility) {
    switch (visibility) {
      case 'public':
        return Icons.public;
      case 'home':
        return Icons.home;
      case 'followers':
        return Icons.people;
      case 'specified':
        return Icons.lock;
      default:
        return Icons.help_outline;
    }
  }

  Color _getVisibilityColor(String? visibility, ThemeData theme) {
    switch (visibility) {
      case 'public':
        return Colors.green;
      case 'home':
        return Colors.blue;
      case 'followers':
        return Colors.orange;
      case 'specified':
        return Colors.purple;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildRawDataButton(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showRawData = !_showRawData;
              });
            },
            icon: Icon(
              _showRawData ? Icons.visibility_off : Icons.code,
              size: 18,
            ),
            label: Text(
              _showRawData ? 'note_detail_hide_raw_data'.tr() : 'note_detail_show_raw_data'.tr(),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (_showRawData) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(50),
              ),
            ),
            child: SelectableText(
              _getNoteRawData(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getNoteRawData() {
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  "id": "${widget.note.id}",');
    buffer.writeln('  "createdAt": "${widget.note.createdAt.toIso8601String()}",');
    if (widget.note.text != null) {
      buffer.writeln('  "text": "${widget.note.text}",');
    }
    if (widget.note.cw != null) {
      buffer.writeln('  "cw": "${widget.note.cw}",');
    }
    buffer.writeln('  "userId": "${widget.note.userId}",');
    buffer.writeln('  "visibility": "${widget.note.visibility}",');
    buffer.writeln('  "localOnly": ${widget.note.localOnly},');
    buffer.writeln('  "renoteCount": ${widget.note.renoteCount},');
    buffer.writeln('  "repliesCount": ${widget.note.repliesCount},');
    buffer.writeln('  "reactionCount": ${widget.note.reactions.values.fold(0, (sum, count) => sum + count)},');
    buffer.writeln('  "fileIds": [${widget.note.fileIds.map((id) => '"$id"').join(', ')}],');
    if (widget.note.replyId != null) {
      buffer.writeln('  "replyId": "${widget.note.replyId}",');
    }
    if (widget.note.renoteId != null) {
      buffer.writeln('  "renoteId": "${widget.note.renoteId}",');
    }
    buffer.writeln('}');
    return buffer.toString();
  }
}
