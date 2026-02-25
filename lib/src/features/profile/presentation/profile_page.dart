import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import '../../auth/application/auth_service.dart';
import '../../auth/domain/account.dart';
import '../../auth/presentation/widgets/add_account_dialog.dart';
import '../../misskey/domain/misskey_user.dart';
import '../../misskey/application/misskey_notifier.dart';
import '../../flarum/application/flarum_providers.dart';
import '../../flarum/data/models/user.dart' as flarum_model;
import '../../common/presentation/pages/media_viewer_page.dart';
import '../../common/presentation/widgets/media/media_item.dart';
import '../../../core/navigation/navigation.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 900;
    final bannerHeight = isWideScreen ? 350.0 : 200.0;

    final selectedMisskey = ref
        .watch(selectedMisskeyAccountProvider)
        .asData
        ?.value;
    final selectedFlarum = ref
        .watch(selectedFlarumAccountProvider)
        .asData
        ?.value;
    final primaryAccount = selectedMisskey ?? selectedFlarum;

    final misskeyUser = primaryAccount?.platform == 'misskey'
        ? ref.watch(misskeyMeProvider).asData?.value
        : null;

    final flarumUser = primaryAccount?.platform == 'flarum'
        ? ref.watch(flarumCurrentUserProvider).asData?.value
        : null;

    final bool isLoggedIn = primaryAccount != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: Breakpoints.small.isActive(context)
                ? IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => ref
                        .read(navigationControllerProvider.notifier)
                        .openDrawer(),
                  )
                : null,
            title: Text('nav_me'.tr()),
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
                    if (isLoggedIn)
                      GestureDetector(
                        onTap: misskeyUser?.bannerUrl != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MediaViewerPage(
                                      mediaItems: [
                                        MediaItem(
                                          url: misskeyUser!.bannerUrl!,
                                          type: MediaType.image,
                                          fileName: 'banner',
                                        ),
                                      ],
                                      heroTag:
                                          'profile_banner_${misskeyUser.id}',
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Hero(
                          tag: 'profile_banner_${misskeyUser?.id ?? 'default'}',
                          child: Container(
                            height: bannerHeight,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              image: misskeyUser?.bannerUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        misskeyUser!.bannerUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              gradient: misskeyUser?.bannerUrl == null
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
                      )
                    else
                      Container(
                        height: bannerHeight,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primaryContainer,
                              theme.colorScheme.primary,
                            ],
                          ),
                        ),
                      ),
                    if (isLoggedIn)
                      _buildLoggedInHeader(
                        context,
                        primaryAccount,
                        misskeyUser,
                        flarumUser,
                      )
                    else
                      _buildLoggedOutHeader(context),
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
                if (isLoggedIn)
                  Positioned(
                    top: bannerHeight - 45,
                    left: 20,
                    child: Hero(
                      tag:
                          'profile_avatar_${misskeyUser?.id ?? primaryAccount.id}',
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
                          backgroundImage:
                              (misskeyUser?.avatarUrl ??
                                      primaryAccount.avatarUrl) !=
                                  null
                              ? NetworkImage(
                                  misskeyUser?.avatarUrl ??
                                      primaryAccount.avatarUrl!,
                                )
                              : null,
                          child:
                              (misskeyUser?.avatarUrl ??
                                      primaryAccount.avatarUrl) ==
                                  null
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
      ),
    );
  }

  Widget _buildLoggedInHeader(
    BuildContext context,
    Account primaryAccount,
    MisskeyUser? misskeyUser,
    flarum_model.User? flarumUser,
  ) {
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
                        offset: const Offset(0, -20), // 向上移动5像素
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 115,
                          ), // 为头像留出空间 (头像半径45 + 左边距20 + 边框宽度3 + 间距7)
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    misskeyUser?.name ??
                                        primaryAccount.name ??
                                        primaryAccount.username ??
                                        'CyaniUser',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (misskeyUser != null &&
                                      misskeyUser.badgeRoles.isNotEmpty)
                                    ...misskeyUser.badgeRoles.map((role) {
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
                                '@${misskeyUser?.username ?? primaryAccount.username}@${primaryAccount.host}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
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
                  child: _buildUserStats(context, misskeyUser, flarumUser),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息部分，为头像留出空间
                Transform.translate(
                  offset: const Offset(0, -20), // 向上移动5像素
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 115,
                    ), // 为头像留出空间 (头像半径45 + 左边距20 + 边框宽度3 + 间距7)
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              misskeyUser?.name ??
                                  primaryAccount.name ??
                                  primaryAccount.username ??
                                  'CyaniUser',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (misskeyUser != null &&
                                misskeyUser.badgeRoles.isNotEmpty)
                              ...misskeyUser.badgeRoles.map((role) {
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
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                        Text(
                          '@${misskeyUser?.username ?? primaryAccount.username}@${primaryAccount.host}',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          // 个人简介
          if (misskeyUser?.description != null &&
              misskeyUser!.description!.isNotEmpty)
            Transform.translate(
              offset: const Offset(0, -25), // 向上移动20像素
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 4),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final text = misskeyUser.description!;
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
          if (!isWideScreen) _buildUserStats(context, misskeyUser, flarumUser),
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

  Widget _buildLoggedOutHeader(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'misskey_page_no_account_title'.tr(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'misskey_page_no_account_subtitle'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.9),
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withAlpha(51), // 0.2 * 255
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAccountDialog(context),
            icon: const Icon(Icons.login),
            label: Text('misskey_page_login_now'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    AddAccountBottomSheet.show(context);
  }

  Widget _buildUserStats(
    BuildContext context,
    MisskeyUser? misskeyUser,
    flarum_model.User? flarumUser,
  ) {
    if (misskeyUser == null && flarumUser == null) {
      return const SizedBox.shrink();
    }

    final List<Widget> stats = [];

    if (misskeyUser != null) {
      // Misskey Stats
      if (misskeyUser.createdAt != null) {
        stats.add(
          _buildStatItem(
            context,
            'Joined',
            DateFormat.yMMMd().format(misskeyUser.createdAt!),
          ),
        );
      }
      if (misskeyUser.notesCount != null) {
        stats.add(
          _buildStatItem(
            context,
            'user_details_notes_count'.tr(),
            _formatCount(misskeyUser.notesCount!),
          ),
        );
      }
      if (misskeyUser.followingCount != null) {
        stats.add(
          _buildStatItem(
            context,
            'user_details_following'.tr(),
            _formatCount(misskeyUser.followingCount!),
          ),
        );
      }
      if (misskeyUser.followersCount != null) {
        stats.add(
          _buildStatItem(
            context,
            'user_details_followers'.tr(),
            _formatCount(misskeyUser.followersCount!),
          ),
        );
      }
    } else if (flarumUser != null) {
      // Flarum Stats
      // Join Time
      stats.add(
        _buildStatItem(
          context,
          'Joined',
          DateFormat.yMMMd().format(DateTime.parse(flarumUser.joinTime)),
        ),
      );

      // Posts (Discussions)
      stats.add(
        _buildStatItem(
          context,
          'user_details_discussions'.tr(),
          _formatCount(flarumUser.discussionCount),
        ),
      );

      // Recovered (Comments)
      stats.add(
        _buildStatItem(
          context,
          'user_details_comments'.tr(),
          _formatCount(flarumUser.commentCount),
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
