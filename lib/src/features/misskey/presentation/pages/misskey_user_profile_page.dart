import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/application/misskey_user_notifier.dart';
import '/src/features/misskey/domain/misskey_user.dart';

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
    final isWideScreen = MediaQuery.of(context).size.width > 900;
    final bannerHeight = isWideScreen ? 350.0 : 200.0;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(user.name ?? user.username),
          centerTitle: true,
          floating: true,
          pinned: true,
          snap: true,
        ),
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  // 背景图片
                  Hero(
                    tag: 'profile_banner_${user.id}',
                    child: Container(
                      height: bannerHeight,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        image: user.bannerUrl != null
                            ? DecorationImage(
                                image: NetworkImage(user.bannerUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        gradient: user.bannerUrl == null
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primaryContainer,
                                  theme.colorScheme.primary,
                                ],
                              )
                            : null,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              theme.colorScheme.surface.withAlpha(100),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildUserHeader(context, user),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [],
                    ),
                  ),
                ],
              ),
              // 头像显示在最顶层
              Positioned(
                top: bannerHeight - 45,
                left: 20,
                child: Hero(
                  tag: 'profile_avatar_${user.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withAlpha(50),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeader(BuildContext context, MisskeyUser user) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息和统计信息
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 用户信息部分，为头像留出空间
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 115,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    user.name ?? user.username,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (user.badgeRoles.isNotEmpty)
                                    ...user.badgeRoles.map((role) {
                                      final name = role['name'] as String?;
                                      if (name == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                              Text(
                                '@${user.username}${user.host != null ? "@${user.host}" : ""}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () {}, // Follow action
                                child: Text('user_follow'.tr()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _buildUserStats(context, user),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息部分，为头像留出空间
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 115,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              user.name ?? user.username,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (user.badgeRoles.isNotEmpty)
                              ...user.badgeRoles.map((role) {
                                final name = role['name'] as String?;
                                if (name == null) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                        Text(
                          '@${user.username}${user.host != null ? "@${user.host}" : ""}',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {}, // Follow action
                          child: Text('user_follow'.tr()),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          // 个人简介
          if (user.description != null && user.description!.isNotEmpty)
            Transform.translate(
              offset: const Offset(0, -25),
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 4),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final text = user.description!;
                    final style = TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    );

                    final textPainter = TextPainter(
                      text: TextSpan(text: text, style: style),
                      maxLines: 10,
                      textDirection: ui.TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth);

                    final isOverflown = textPainter.didExceedMaxLines;

                    if (isOverflown) {
                      return InkWell(
                        onTap: () => _showFullBioCard(context, text),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'user_details_bio_truncated'.tr(),
                              style: style.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SelectableText(text, style: style);
                  },
                ),
              ),
            ),

          // 用户统计信息（仅在窄屏时显示）
          if (!isWideScreen) _buildUserStats(context, user),
        ],
      ),
    );
  }

  void _showFullBioCard(BuildContext context, String bio) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'user_details_bio'.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: SelectableText(
                      bio,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('post_close'.tr()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, MisskeyUser user) {
    final List<Widget> stats = [];

    if (user.createdAt != null) {
      stats.add(
        _buildStatItem(
          context,
          'Joined',
          DateFormat.yMMMd().format(user.createdAt!),
        ),
      );
    }
    if (user.notesCount != null) {
      stats.add(
        _buildStatItem(
          context,
          'user_details_notes_count'.tr(),
          _formatCount(user.notesCount!),
        ),
      );
    }
    if (user.followingCount != null) {
      stats.add(
        _buildStatItem(
          context,
          'user_details_following'.tr(),
          _formatCount(user.followingCount!),
        ),
      );
    }
    if (user.followersCount != null) {
      stats.add(
        _buildStatItem(
          context,
          'user_details_followers'.tr(),
          _formatCount(user.followersCount!),
        ),
      );
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats
          .map(
            (s) => Padding(padding: const EdgeInsets.only(right: 16), child: s),
          )
          .toList(),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count > 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
