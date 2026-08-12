import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/application/misskey_user_notifier.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/features/misskey/domain/misskey_user.dart';
import '/src/features/misskey/domain/note.dart';
import '/src/features/misskey/domain/drive_file.dart';
import '/src/features/misskey/domain/mfm_renderer.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/features/misskey/presentation/widgets/modern_note_card.dart';
import '/src/core/utils/logger.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';
import '/src/shared/widgets/cyani_error_widget.dart';
import '/src/shared/widgets/circle_icon_button.dart';

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
    extends ConsumerState<MisskeyUserProfilePage>
    with SingleTickerProviderStateMixin {
  static int _heroCounter = 0;
  late final String _heroSuffix;
  late final MfmRenderer _mfmRenderer;
  String? _loadedEmojiUserId;
  late TabController _tabController;
  bool _isFollowing = false;
  bool _isFollowedByTarget = false;
  bool _isLoadingRelation = true;

  static const _tabLabels = [
    '概览',
    '帖子',
    '文件',
    '活动',
    '成就',
    '回应',
    '便签',
    '列表',
    '页面',
    'Play',
    '图集',
    '原始数据',
  ];

  @override
  void initState() {
    super.initState();
    _heroSuffix = '_${_heroCounter++}';
    _mfmRenderer = MfmRenderer();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _setupMfmRenderer();
    _loadEmojis(widget.initialUser);
    _loadFollowRelation();
  }

  Future<void> _loadFollowRelation() async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final relation = await repository.getFollowRelation(widget.userId);
      final isFollowing = relation['isFollowing'] ?? false;
      logger.info('Follow relation for ${widget.userId}: isFollowing=$isFollowing');

      // Check if the target user follows the current user
      // by fetching a page of our followers and checking membership
      bool isFollowedByTarget = false;
      try {
        final account = ref.read(selectedMisskeyAccountProvider).value;
        if (account != null) {
          // Account.id format is "userId@host", extract userId
          final myUserId = account.id.split('@').first;
          final followers = await repository.getFollowers(
            myUserId,
            limit: 100,
          );
          isFollowedByTarget = followers.any(
            (f) => f['id'] == widget.userId,
          );
          logger.info('Target user ${widget.userId} follows me: $isFollowedByTarget');
        }
      } catch (e) {
        logger.error('Error checking if target follows current user: $e');
      }

      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
          _isFollowedByTarget = isFollowedByTarget;
          _isLoadingRelation = false;
        });
      }
    } catch (e) {
      logger.error('Error loading follow relation: $e');
      if (mounted) {
        setState(() {
          _isLoadingRelation = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      if (_isFollowing) {
        await repository.deleteFollow(widget.userId);
      } else {
        await repository.createFollow(widget.userId);
      }
      // Refresh the follow relation after the action
      await _loadFollowRelation();
    } catch (e) {
      logger.error('Error toggling follow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFollowing ? '取消关注失败' : '关注失败',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    return Scaffold(
      body: userAsync.when(
        data: (user) => _buildProfile(context, user),
        loading: () => widget.initialUser != null
            ? _buildProfile(context, widget.initialUser!, isLoading: true)
            : const Center(child: CyaniLoadingIndicator()),
        error: (err, stack) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: CyaniErrorWidget(message: err.toString()),
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

    final isWideScreen = MediaQuery.of(context).size.width > 900;
    final bannerHeight = isWideScreen ? 350.0 : 200.0;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(misskeyUserProvider(widget.userId).notifier).refresh(),
      child: isWideScreen
          ? _buildWideLayout(context, user, bannerHeight, isLoading)
          : _buildNarrowLayout(context, user, bannerHeight, isLoading),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    MisskeyUser user,
    double bannerHeight,
    bool isLoading,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Left panel - 1:1 split
        Expanded(
          child: Stack(
            children: [
              _buildLeftPanel(context, user, bannerHeight),
              // Back button
              Positioned(
                top: 16,
                left: 16,
                child: CircleIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
        // Right panel - 1:1 split
        Expanded(
          child: Column(
            children: [
              // Tab bar
              Container(
                color: theme.colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                  tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
                ),
              ),
              // Tab content
              Expanded(
                child: _buildTabContent(user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    MisskeyUser user,
    double bannerHeight,
    bool isLoading,
  ) {
    final theme = Theme.of(context);

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              leading: CircleIconButton(
                icon: Icons.arrow_back,
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
            child: _buildLeftPanel(context, user, bannerHeight),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicatorColor: theme.colorScheme.primary,
                tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
              ),
            ),
          ),
        ];
      },
      body: _buildTabContent(user),
    );
  }

  Widget _buildLeftPanel(BuildContext context, MisskeyUser user, double bannerHeight) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Banner
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

        // Avatar + Name section
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Transform.translate(
                offset: const Offset(0, -45),
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

              // Name + Username
              Transform.translate(
                offset: const Offset(0, -20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Badge roles
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
                            if (name == null) return const SizedBox.shrink();
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

                    // Username
                    Text(
                      '@${user.username}${user.host != null ? "@${user.host}" : ""}',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Follow button
                    _buildFollowButton(user),

                    const SizedBox(height: 16),

                    // Description (MFM)
                    if (user.description != null &&
                        user.description!.isNotEmpty) ...[
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
                      const SizedBox(height: 16),
                    ],

                    // Registration time
                    if (user.createdAt != null) ...[
                      _buildInfoRow(
                        Icons.calendar_today,
                        '注册时间',
                        DateFormat('yyyy/MM/dd HH:mm:ss').format(user.createdAt!),
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.access_time,
                        '',
                        _formatTimeAgo(user.createdAt!),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Stats
                    _buildStatsRow(user),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildFollowButton(MisskeyUser user) {
    if (_isLoadingRelation) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          onPressed: _toggleFollow,
          style: FilledButton.styleFrom(
            backgroundColor: _isFollowing
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : null,
            foregroundColor: _isFollowing
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
          child: Text(_isFollowing ? 'user_following'.tr() : 'user_follow'.tr()),
        ),
        if (_isFollowedByTarget) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'user_following_you'.tr(),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        if (label.isNotEmpty) ...[
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(MisskeyUser user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('帖子', _formatCount(user.notesCount ?? 0)),
        _buildStatItem('关注中', _formatCount(user.followingCount ?? 0)),
        _buildStatItem('关注者', _formatCount(user.followersCount ?? 0)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(MisskeyUser user) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(user),
        _buildNotesTab(user),
        _buildFilesTab(user),
        _buildComingSoon('活动'),
        _buildComingSoon('成就'),
        _buildComingSoon('回应'),
        _buildComingSoon('便签'),
        _buildComingSoon('列表'),
        _buildComingSoon('页面'),
        _buildComingSoon('Play'),
        _buildGalleryTab(user),
        _buildRawDataTab(user),
      ],
    );
  }

  // ===== Tab: Overview =====
  Widget _buildOverviewTab(MisskeyUser user) {
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

    if (user.followedMessage != null && user.followedMessage!.isNotEmpty) {
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
                size: 16, color: theme.colorScheme.onSurfaceVariant),
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
                size: 16, color: theme.colorScheme.onSurfaceVariant),
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
                size: 16, color: theme.colorScheme.onSurfaceVariant),
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
      return Center(
        child: Text(
          '暂无信息',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView(
      children: sections,
    );
  }

  // ===== Tab: Notes =====
  Widget _buildNotesTab(MisskeyUser user) {
    return _UserNotesTab(userId: user.id);
  }

  // ===== Tab: Files =====
  Widget _buildFilesTab(MisskeyUser user) {
    return _UserFilesTab(userId: user.id);
  }

  // ===== Tab: Gallery =====
  Widget _buildGalleryTab(MisskeyUser user) {
    return _UserGalleryTab(userId: user.id);
  }

  // ===== Tab: Raw Data =====
  Widget _buildRawDataTab(MisskeyUser user) {
    final theme = Theme.of(context);
    final json = user.toJson();
    final prettyJson = const JsonEncoder.withIndent('  ').convert(json);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            prettyJson,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoon(String tabName) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
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

  String _formatCount(int count) {
    if (count > 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

// ===== User Notes Tab Widget =====
class _UserNotesTab extends ConsumerStatefulWidget {
  final String userId;

  const _UserNotesTab({required this.userId});

  @override
  ConsumerState<_UserNotesTab> createState() => _UserNotesTabState();
}

class _UserNotesTabState extends ConsumerState<_UserNotesTab>
    with AutomaticKeepAliveClientMixin {
  final List<Note> _notes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _untilId;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadNotes() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final notes = await repository.getUserNotes(
        widget.userId,
        limit: 20,
        untilId: _untilId,
      );

      if (mounted) {
        setState(() {
          _notes.addAll(notes);
          _hasMore = notes.length >= 20;
          if (notes.isNotEmpty) _untilId = notes.last.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.error('Error loading user notes: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    await _loadNotes();
  }

  Future<void> _refresh() async {
    setState(() {
      _notes.clear();
      _untilId = null;
      _hasMore = true;
    });
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_notes.isEmpty && _isLoading) {
      return const Center(child: CyaniLoadingIndicator());
    }

    if (_notes.isEmpty) {
      return Center(
        child: Text(
          '暂无帖子',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notes.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notes.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CyaniLoadingIndicator()),
            );
          }
          return ModernNoteCard(
            note: _notes[index],
          );
        },
      ),
    );
  }
}

// ===== User Files Tab Widget =====
class _UserFilesTab extends ConsumerStatefulWidget {
  final String userId;

  const _UserFilesTab({required this.userId});

  @override
  ConsumerState<_UserFilesTab> createState() => _UserFilesTabState();
}

class _UserFilesTabState extends ConsumerState<_UserFilesTab>
    with AutomaticKeepAliveClientMixin {
  final List<DriveFile> _files = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _untilId;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFiles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFiles() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final files = await repository.getUserDriveFiles(
        widget.userId,
        limit: 30,
        untilId: _untilId,
      );

      if (mounted) {
        setState(() {
          _files.addAll(files);
          _hasMore = files.length >= 30;
          if (files.isNotEmpty) _untilId = files.last.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.error('Error loading user files: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    await _loadFiles();
  }

  Future<void> _refresh() async {
    setState(() {
      _files.clear();
      _untilId = null;
      _hasMore = true;
    });
    await _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_files.isEmpty && _isLoading) {
      return const Center(child: CyaniLoadingIndicator());
    }

    if (_files.isEmpty) {
      return Center(
        child: Text(
          '暂无文件',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: _files.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _files.length) {
            return const Center(child: CyaniLoadingIndicator());
          }
          return _FileGridItem(file: _files[index]);
        },
      ),
    );
  }
}

class _FileGridItem extends StatelessWidget {
  final DriveFile file;

  const _FileGridItem({required this.file});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImage = file.type.startsWith('image/');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: isImage && file.thumbnailUrl != null
          ? Image.network(
              file.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholder(theme),
            )
          : _buildPlaceholder(theme),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    final icon = _getIconForType(file.type);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(
            file.name,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.startsWith('image/')) return Icons.image;
    if (type.startsWith('video/')) return Icons.video_file;
    if (type.startsWith('audio/')) return Icons.audio_file;
    if (type == 'application/pdf') return Icons.picture_as_pdf;
    if (type.contains('zip') || type.contains('archive')) return Icons.archive;
    return Icons.insert_drive_file;
  }
}

// ===== User Gallery Tab Widget =====
class _UserGalleryTab extends ConsumerStatefulWidget {
  final String userId;

  const _UserGalleryTab({required this.userId});

  @override
  ConsumerState<_UserGalleryTab> createState() => _UserGalleryTabState();
}

class _UserGalleryTabState extends ConsumerState<_UserGalleryTab>
    with AutomaticKeepAliveClientMixin {
  final List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _untilId;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final posts = await repository.getUserGalleryPosts(
        widget.userId,
        limit: 10,
        untilId: _untilId,
      );

      if (mounted) {
        setState(() {
          _posts.addAll(posts);
          _hasMore = posts.length >= 10;
          if (posts.isNotEmpty) _untilId = posts.last['id'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.error('Error loading user gallery posts: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;
    await _loadPosts();
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _untilId = null;
      _hasMore = true;
    });
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_posts.isEmpty && _isLoading) {
      return const Center(child: CyaniLoadingIndicator());
    }

    if (_posts.isEmpty) {
      return Center(
        child: Text(
          '暂无图集',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Center(child: CyaniLoadingIndicator());
          }
          return _GalleryGridItem(post: _posts[index]);
        },
      ),
    );
  }
}

class _GalleryGridItem extends StatelessWidget {
  final Map<String, dynamic> post;

  const _GalleryGridItem({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = post['title'] as String? ?? '';
    final file = post['file'] as Map<String, dynamic>?;
    final thumbnailUrl = file?['thumbnailUrl'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: thumbnailUrl != null
                ? Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(
                          child: Icon(
                            Icons.image,
                            size: 32,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                  )
                : Center(
                    child: Icon(
                      Icons.image,
                      size: 32,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarDelegate(this.tabBar);

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
