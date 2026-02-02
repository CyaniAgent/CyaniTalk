import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../application/misskey_user_notifier.dart';
import '../../domain/misskey_user.dart';
import '../widgets/retryable_network_image.dart';

class MisskeyUserProfilePage extends ConsumerWidget {
  final String userId;
  final MisskeyUser? initialUser;

  const MisskeyUserProfilePage({
    super.key,
    required this.userId,
    this.initialUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(misskeyUserProvider(userId));
    final theme = Theme.of(context);
    final mikuGreen = const Color(0xFF39C5BB);

    return Scaffold(
      body: userAsync.when(
        data: (user) => _buildProfile(context, user, theme, mikuGreen),
        loading: () => initialUser != null 
            ? _buildProfile(context, initialUser!, theme, mikuGreen, isLoading: true)
            : const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, MisskeyUser user, ThemeData theme, Color mikuGreen, {bool isLoading = false}) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (user.bannerUrl != null)
                  RetryableNetworkImage(
                    url: user.bannerUrl!,
                    fit: BoxFit.cover,
                  )
                else
                  Container(color: mikuGreen.withValues(alpha: 0.2)),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              user.name ?? user.username,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(16, -40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: FilledButton.tonal(
                        onPressed: () {}, // Follow action
                        child: Text('user_follow'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? user.username,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '@${user.username}${user.host != null ? "@${user.host}" : ""}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                    ),
                    if (user.description != null && user.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(user.description!),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStat(context, user.followingCount?.toString() ?? '0', 'user_following'.tr()),
                        const SizedBox(width: 24),
                        _buildStat(context, user.followersCount?.toString() ?? '0', 'user_followers'.tr()),
                        const SizedBox(width: 24),
                        _buildStat(context, user.notesCount?.toString() ?? '0', 'user_notes'.tr()),
                      ],
                    ),
                    const Divider(height: 32),
                    if (isLoading)
                      const Center(child: LinearProgressIndicator())
                    else
                      const Center(child: Text('User timeline coming soon...')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String count, String label) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}