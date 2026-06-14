import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/application/misskey_user_notifier.dart';
import '/src/features/misskey/domain/misskey_user.dart';
import '/src/features/misskey/domain/mfm_renderer.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/core/utils/logger.dart';

class MisskeyUserProfilePage extends ConsumerStatefulWidget {
  final String userId;
  final MisskeyUser? initialUser;

  const MisskeyUserProfilePage({
    super.key,
    required this.userId,
    this.initialUser,
  });

  @override
  ConsumerState<MisskeyUserProfilePage> createState() =>
      _MisskeyUserProfilePageState();
}

class _MisskeyUserProfilePageState
    extends ConsumerState<MisskeyUserProfilePage> {
  static int _heroCounter = 0;
  late final String _heroSuffix;
  late final MfmRenderer _mfmRenderer;
  String? _loadedEmojiUserId;

  static const _tabLabels = [
    '信息',
    '帖子',
    '文件',
    '活动',
    '便签',
    '列表',
    '页面',
    'Play',
    '图集',
  ];

  @override
  void initState() {
    super.initState();
    _heroSuffix = '_${_heroCounter++}';
    _mfmRenderer = MfmRenderer();
    _setupMfmRenderer();
    _loadEmojis(widget.initialUser);
  }

  @override
  void dispose() {
    _mfmRenderer.dispose();
    super.dispose();
  }

  void _setupMfmRenderer() {
    _mfmRenderer.setApiEmojiLoader((emojiName) async {
      try {
        final repository = await ref.read(misskeyRepositoryProvider.future);
        final emojiDetail = await repository.getEmoji(emojiName);
        return emojiDetail.url;
      } catch (e) {
        logger.error('Error loading emoji: $e');
        return null;
      }
    });
  }

  void _loadEmojis(MisskeyUser? user) {
    if (user?.emojis != null && user!.emojis!.isNotEmpty) {
      _mfmRenderer.addEmojisToCache(user.emojis!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(misskeyUserProvider(widget.userId));

    return DefaultTabController(
      length: _tabLabels.length,
      child: Scaffold(
        body: userAsync.when(
          data: (user) => _buildProfile(context, user),
          loading: () => widget.initialUser != null
              ? _buildProfile(context, widget.initialUser!, isLoading: true)
              : const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, MisskeyUser user,
      {bool isLoading = false}) {
    if (user.id != _loadedEmojiUserId &&
        user.emojis != null &&
        user.emojis!.isNotEmpty) {
      _loadedEmojiUserId = user.id;
      _mfmRenderer.addEmojisToCache(user.emojis!);
    }

    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 900;
    final bannerHeight = isWideScreen ? 350.0 : 200.0;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle:
                NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
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
          ),
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Hero(
                      tag: 'profile_banner_${user.id}$_heroSuffix',
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
                  ],
                ),
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
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                isScrollable: true,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor:
                    theme.colorScheme.onSurfaceVariant,
                indicatorColor: theme.colorScheme.primary,
                tabs: _tabLabels
                    .map((label) => Tab(text: label))
                    .toList(),
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        children: [
          _buildInfoTab(user),
          _buildComingSoon('帖子'),
          _buildComingSoon('文件'),
          _buildComingSoon('活动'),
          _buildComingSoon('便签'),
          _buildComingSoon('列表'),
          _buildComingSoon('页面'),
          _buildComingSoon('Play'),
          _buildComingSoon('图集'),
        ],
      ),
    );
  }

  Widget _buildComingSoon(String tabName) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (context) => CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView
                  .sliverOverlapAbsorberHandleFor(context),
            ),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant
                          .withAlpha(100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$tabName 功能即将推出…',
                      style: TextStyle(
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
    );
  }

  Widget _buildInfoTab(MisskeyUser user) {
    final theme = Theme.of(context);
    final sections = <Widget>[];

    void addField(String label, Widget content) {
      sections.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              content,
            ],
          ),
        ),
      );
      sections.add(Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: theme.colorScheme.outlineVariant,
      ));
    }

    if (user.followedMessage != null &&
        user.followedMessage!.isNotEmpty) {
      addField(
        '给关注者的消息',
        _mfmRenderer.processTextToRichText(
          user.followedMessage!,
          context,
          textStyle: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
          onEmojiLoaded: () {
            if (mounted) setState(() {});
          },
        ),
      );
    }

    if (user.description != null && user.description!.isNotEmpty) {
      addField(
        '描述',
        _mfmRenderer.processTextToRichText(
          user.description!,
          context,
          textStyle: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
          onEmojiLoaded: () {
            if (mounted) setState(() {});
          },
        ),
      );
    }

    if (user.location != null && user.location!.isNotEmpty) {
      addField(
        '位置',
        Row(
          children: [
            Icon(Icons.location_on_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              user.location!,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (user.birthday != null && user.birthday!.isNotEmpty) {
      addField(
        '生日',
        Row(
          children: [
            Icon(Icons.cake_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              user.birthday!,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (user.lang != null && user.lang!.isNotEmpty) {
      addField(
        '语言',
        Row(
          children: [
            Icon(Icons.language,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              user.lang!,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (user.fields.isNotEmpty) {
      addField('附加信息', _buildFields(user.fields));
    }

    if (sections.isEmpty) {
      return SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView
                    .sliverOverlapAbsorberHandleFor(context),
              ),
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    '暂无信息',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (context) => CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView
                  .sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sections,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFields(List<Map<String, dynamic>> fields) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map((field) {
        final name = field['name'] as String? ?? '';
        final value = field['value'] as String? ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              _mfmRenderer.processTextToRichText(
                value,
                context,
                textStyle: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
                onEmojiLoaded: () {
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
        );
      }).toList(),
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
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 115),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                crossAxisAlignment:
                                    WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    user.name ?? user.username,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (user.badgeRoles.isNotEmpty)
                                    ...user.badgeRoles.map((role) {
                                      final name =
                                          role['name'] as String?;
                                      if (name == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color:
                                                theme.colorScheme.primary,
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
                                  color: theme
                                      .colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed:
                                    () {}, // Follow action
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
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 115),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          crossAxisAlignment:
                              WrapCrossAlignment.center,
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
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.primaryContainer,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          theme.colorScheme.primary,
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
                            color:
                                theme.colorScheme.onSurfaceVariant,
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

          if (!isWideScreen) _buildUserStats(context, user),
        ],
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
            (s) =>
                Padding(padding: const EdgeInsets.only(right: 16), child: s),
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
