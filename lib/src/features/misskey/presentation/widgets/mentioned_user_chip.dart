import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/core/utils/logger.dart';
import '/src/features/misskey/data/misskey_repository.dart';

class MentionedUserChip extends ConsumerStatefulWidget {
  final String username;
  final String? host;
  final String acct;
  final void Function(String userId) onTap;

  const MentionedUserChip({
    super.key,
    required this.username,
    this.host,
    required this.acct,
    required this.onTap,
  });

  @override
  ConsumerState<MentionedUserChip> createState() => _MentionedUserChipState();
}

class _MentionedUserChipState extends ConsumerState<MentionedUserChip> {
  String? _avatarUrl;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final user = await repository.findUserByUsername(
        widget.username,
        host: widget.host,
      );
      if (mounted) {
        setState(() {
          _avatarUrl = user.avatarUrl;
          _userId = user.id;
        });
      }
    } catch (e) {
      logger.debug('MentionedUserChip: Could not load user: $e');
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return GestureDetector(
      onTap: () {
        if (_userId != null) {
          widget.onTap(_userId!);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 2, right: 8),
        decoration: BoxDecoration(
          color: primaryColor.withAlpha(25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primaryColor.withAlpha(60), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: primaryColor.withAlpha(40),
              backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                  ? NetworkImage(_avatarUrl!)
                  : null,
              child: _avatarUrl == null || _avatarUrl!.isEmpty
                  ? Text(
                      widget.username.isNotEmpty
                          ? widget.username[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '@${widget.username}',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
