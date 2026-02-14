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

    return Scaffold(
      body: userAsync.when(
        data: (user) => _buildProfile(context, user, theme),
        loading: () => initialUser != null
            ? _buildProfile(context, initialUser!, theme, isLoading: true)
            : const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context,
    MisskeyUser user,
    ThemeData theme, {
    bool isLoading = false,
  }) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: user.bannerUrl != null
                ? RetryableNetworkImage(url: user.bannerUrl!, fit: BoxFit.cover)
                : Container(color: theme.colorScheme.primary.withAlpha(50)),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? user.username,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${user.username}${user.host != null ? "@${user.host}" : ""}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () {}, // Follow action
                      child: Text('user_follow'.tr()),
                    ),
                  ],
                ),
              ),
              if (user.description != null && user.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(user.description!),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStat(
                      context,
                      user.followingCount?.toString() ?? '0',
                      'user_following'.tr(),
                    ),
                    const SizedBox(width: 32),
                    _buildStat(
                      context,
                      user.followersCount?.toString() ?? '0',
                      'user_followers'.tr(),
                    ),
                    const SizedBox(width: 32),
                    _buildStat(
                      context,
                      user.notesCount?.toString() ?? '0',
                      'user_notes'.tr(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              if (isLoading)
                const Center(child: LinearProgressIndicator())
              else
                const Center(child: Text('User timeline coming soon...')),
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
