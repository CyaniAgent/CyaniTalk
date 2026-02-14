// Misskey功能的主页面
//
// 该文件包含MisskeyPage组件，是Misskey功能模块的主入口，
// 管理不同Misskey页面的切换和导航。
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/audio_engine.dart';
import '../../auth/application/auth_service.dart';
import '../../../routing/router.dart';
import '../../../core/navigation/navigation.dart';
import '../../../core/navigation/sub_navigation_notifier.dart';
import '../application/misskey_notifier.dart';
import 'pages/misskey_timeline_page.dart';
import 'pages/misskey_notes_page.dart';
import 'pages/misskey_antennas_page.dart';
import 'pages/misskey_channels_page.dart';
import 'pages/misskey_explore_page.dart';
import 'pages/misskey_follow_requests_page.dart';
import 'pages/misskey_announcements_page.dart';
import 'pages/misskey_aiscript_console_page.dart';
import 'pages/misskey_post_page.dart';

/// Misskey功能模块的主页面组件
///
/// 负责管理不同Misskey页面的切换，包含侧边栏导航、顶部导航栏和浮动操作按钮。
class MisskeyPage extends ConsumerStatefulWidget {
  /// 创建一个新的MisskeyPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyPage({super.key});

  /// 创建MisskeyPage的状态管理对象
  @override
  ConsumerState<MisskeyPage> createState() => _MisskeyPageState();
}

/// MisskeyPage的状态管理类
class _MisskeyPageState extends ConsumerState<MisskeyPage> {
  @override
  void initState() {
    super.initState();
    // Trigger initial refresh for the current sub-page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final selectedIndex = ref.read(misskeySubIndexProvider);
        _refreshCurrentSubPage(selectedIndex);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshCurrentSubPage(int index) {
    // Only refresh if account is selected
    final account = ref.read(selectedMisskeyAccountProvider).value;
    if (account == null) return;

    switch (index) {
      case 0: // Timeline
        // MisskeyTimelineNotifier uses 'type' as arg, we need to know current active type
        // Usually handled by the specific timeline widget building, but we can force it here
        // if we have a way to track the active type provider.
        // For now, build handles auto-refresh via loadLatestData with 2s delay.
        // We can't easily invalidate a parameterized provider without knowing the param.
        break;
      case 1: // Clips
        ref.invalidate(misskeyClipsProvider);
        break;
      case 3: // Channels
        ref.invalidate(misskeyChannelsProvider);
        break;
      case 6: // Announcements
        // Add if there is a provider
        break;
    }
  }

  /// 所有可用的Misskey页面列表
  final List<Widget> _pages = const [
    MisskeyTimelinePage(key: ValueKey('timeline')),
    MisskeyNotesPage(key: ValueKey('notes')),
    MisskeyAntennasPage(key: ValueKey('antennas')),
    MisskeyChannelsPage(key: ValueKey('channels')),
    MisskeyExplorePage(key: ValueKey('explore')),
    MisskeyFollowRequestsPage(key: ValueKey('follow_requests')),
    MisskeyAnnouncementsPage(key: ValueKey('announcements')),
    MisskeyAiScriptConsolePage(key: ValueKey('aiscript_console')),
  ];

  /// 显示在线用户浮动卡片
  void _showOnlineUsersCard(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          child:
              Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    elevation: 10,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_alt_rounded,
                                size: 56,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ).animate().scale(
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'misskey_online_users_title'.tr(),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'misskey_online_users'.tr(
                                  namedArgs: {'count': count.toString()},
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        ref
                                            .read(
                                              misskeyOnlineUsersProvider
                                                  .notifier,
                                            )
                                            .refresh();
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: Text(
                                        'misskey_online_users_refresh'.tr(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(
                                        'misskey_online_users_ok'.tr(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .scale(
                    duration: 400.ms,
                    begin: const Offset(0.8, 0.8),
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(),
        ),
      ),
    );
  }

  /// 对应页面的标题列表
  final List<String> _titles = [
    'misskey_page_timeline'.tr(),
    'misskey_page_clips'.tr(),
    'misskey_page_antennas'.tr(),
    'misskey_page_channels'.tr(),
    'misskey_page_explore'.tr(),
    'misskey_page_follow_requests'.tr(),
    'misskey_page_announcements'.tr(),
    'misskey_page_aiscript_console'.tr(),
  ];

  /// 构建Misskey主页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回包含侧边栏、顶部导航栏和内容区域的Scaffold组件
  @override
  Widget build(BuildContext context) {
    final selectedAccountAsync = ref.watch(selectedMisskeyAccountProvider);
    final selectedIndex = ref.watch(misskeySubIndexProvider);

    // Auto-refresh when switching sub-tabs
    ref.listen(misskeySubIndexProvider, (previous, next) {
      _refreshCurrentSubPage(next);
    });

    return Scaffold(
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              heroTag: 'misskey_fab',
              onPressed: () async {
                logger.info('MisskeyPage: Floating action button pressed');
                // 检查是否已登录 Misskey
                final authState = ref.read(authServiceProvider);
                final hasMisskeyAccount = authState.maybeWhen(
                  data: (accounts) =>
                      accounts.any((a) => a.platform == 'misskey'),
                  orElse: () => false,
                );

                if (hasMisskeyAccount) {
                  // 已登录，打开发布窗口
                  logger.info(
                    'MisskeyPage: Opening post dialog (user logged in)',
                  );
                  showDialog(
                    context: context,
                    builder: (context) => const MisskeyPostPage(),
                  );
                } else {
                  // 未登录，根据当前语言播放提示音
                  logger.info(
                    'MisskeyPage: User not logged in, playing prompt sound',
                  );
                  final isMounted = mounted;
                  final currentContext = context;
                  final scaffoldMessenger = ScaffoldMessenger.of(
                    currentContext,
                  );
                  try {
                    final String soundPath =
                        switch (currentContext.locale.languageCode) {
                          'zh' => 'sounds/SpeechNoti/PleaseLogin-zh.wav',
                          'en' => 'sounds/SpeechNoti/PleaseLogin-en.wav',
                          'ja' => 'sounds/SpeechNoti/PleaseLogin-ja.wav',
                          _ => 'sounds/SpeechNoti/PleaseLogin-default.wav',
                        };
                    await ref.read(audioEngineProvider).playAsset(soundPath);
                    logger.info(
                      'MisskeyPage: Played login prompt sound: $soundPath',
                    );
                  } catch (e) {
                    logger.error('MisskeyPage: Error playing sound: $e');
                  }

                  if (isMounted) {
                    // 使用提前获取的scaffoldMessenger实例，避免BuildContext警告
                    logger.info('MisskeyPage: Showing login prompt snackbar');
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('misskey_page_please_login'.tr()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    // 跳转到 Profile 页面进行登录
                    logger.info(
                      'MisskeyPage: Navigating to profile page for login',
                    );
                    final router = ref.read(goRouterProvider);
                    router.go('/profile');
                  }
                }
              },
              child: const Icon(Icons.edit),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              leading: Breakpoints.small.isActive(context)
                  ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => ref
                          .read(navigationControllerProvider.notifier)
                          .openDrawer(),
                    )
                  : null,
              title: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _titles[selectedIndex],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selectedIndex == 0) ...[
                      const SizedBox(width: 8),
                      ref
                          .watch(misskeyOnlineUsersProvider)
                          .when(
                            data: (count) => InkWell(
                              onTap: () {
                                _showOnlineUsersCard(context, count);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withAlpha(128),
                                                blurRadius: 4,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        )
                                        .animate(
                                          onPlay: (controller) =>
                                              controller.repeat(),
                                        )
                                        .scale(
                                          duration: 1.seconds,
                                          begin: const Offset(1, 1),
                                          end: const Offset(1.3, 1.3),
                                          curve: Curves.easeInOut,
                                        )
                                        .then()
                                        .scale(
                                          duration: 1.seconds,
                                          begin: const Offset(1.3, 1.3),
                                          end: const Offset(1, 1),
                                          curve: Curves.easeInOut,
                                        ),
                                    const SizedBox(width: 6),
                                    Text(
                                      count.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            loading: () => const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (error, stack) => const SizedBox.shrink(),
                          ),
                    ],
                  ],
                ),
              ),
              centerTitle: true,
              floating: true,
              pinned: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'misskey_page_global_search'.tr(),
                  onPressed: () {
                    logger.info(
                      'MisskeyPage: Search button pressed, navigating to /search',
                    );
                    context.push('/search');
                  },
                ),
              ],
            ),
          ];
        },
        body: selectedAccountAsync.when(
          data: (account) {
            if (account == null) {
              return _buildNoAccountState(context);
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final isIncoming = child.key == _pages[selectedIndex].key;
                final inAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation);
                final outAnimation = Tween<Offset>(
                  begin: const Offset(0.0, -0.1),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: isIncoming ? inAnimation : outAnimation,
                    // 如果是正在退出的组件，则屏蔽其辅助功能语义，防止 AXTree 报错
                    child: isIncoming ? child : ExcludeSemantics(child: child),
                  ),
                );
              },
              child: _pages[selectedIndex],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildNoAccountState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'misskey_page_no_account_title'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'misskey_page_no_account_subtitle'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/profile'),
              icon: const Icon(Icons.login),
              label: Text('misskey_page_login_now'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
