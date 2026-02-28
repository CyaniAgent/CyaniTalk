// Misskey功能的主页面
//
// 重构说明：强化了实时监测逻辑，精简了在线人数展示，并优化了动画架构。
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/core/utils/logger.dart';
import '/src/core/services/audio_engine.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/core/navigation/navigation.dart';
import '/src/core/navigation/sub_navigation_notifier.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import '/src/features/misskey/application/misskey_notifications_notifier.dart';
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
class MisskeyPage extends ConsumerStatefulWidget {
  const MisskeyPage({super.key});

  @override
  ConsumerState<MisskeyPage> createState() => _MisskeyPageState();
}

class _MisskeyPageState extends ConsumerState<MisskeyPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // [逻辑修正] 启动时的自动刷新由 MisskeyTimelineNotifier 的 build() 自行管理
    // 它会自动从缓存加载并尝试静默更新，我们不在这里额外干预，防止冲突导致白屏
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      logger.info('MisskeyPage: App resumed, triggering background refresh');
      _triggerBackgroundRefresh();
    }
  }

  void _triggerBackgroundRefresh() {
    try {
      final index = ref.read(misskeySubIndexProvider);
      if (index == 0) {
        // 静默刷新，不使用可能导致状态重置的 invalidate
        ref.read(misskeyTimelineProvider('Global').notifier).refresh();
      }
      // 刷新通知
      ref.read(misskeyNotificationsProvider.notifier).refresh();
    } catch (e) {
      logger.warning('MisskeyPage: Background refresh failed: $e');
    }
  }

  void _triggerRefreshIfNecessary(int index) {
    if (index == 0) { 
      try {
        // 跨标签页回归时，尝试刷新所有活跃时间线
        ref.read(misskeyTimelineProvider('Global').notifier).refresh();
        ref.read(misskeyTimelineProvider('Local').notifier).refresh();
        ref.read(misskeyTimelineProvider('Social').notifier).refresh();
      } catch (e) {
        logger.warning('MisskeyPage: Manual refresh failed: $e');
      }
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

  @override
  Widget build(BuildContext context) {
    final selectedAccountAsync = ref.watch(selectedMisskeyAccountProvider);
    final selectedIndex = ref.watch(misskeySubIndexProvider);

    // [逻辑] 回到时间线时的自动刷新
    ref.listen(misskeySubIndexProvider, (previous, next) {
      if (next == 0 && previous != 0) {
        logger.info('MisskeyPage: Returned to timeline, triggering refresh');
        _triggerRefreshIfNecessary(next);
      }
    });

    return Scaffold(
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              heroTag: 'misskey_fab',
              onPressed: () => _handlePostAction(context),
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
                      onPressed: () => ref.read(navigationControllerProvider.notifier).openDrawer(),
                    )
                  : null,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_titles[selectedIndex]),
                  if (selectedIndex == 0) ...[
                    const SizedBox(width: 8),
                    // 更加彻底的语义屏蔽，并在不可见时停止一切更新
                    const ExcludeSemantics(
                      child: _OnlineUsersBrief(),
                    ),
                  ],
                ],
              ),
              centerTitle: true,
              floating: true,
              pinned: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'misskey_page_global_search'.tr(),
                  onPressed: () => context.push('/search'),
                ),
              ],
            ),
          ];
        },
        body: selectedAccountAsync.when(
          data: (account) {
            if (account == null) return _buildNoAccountState(context);
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final isIncoming = child.key == _pages[selectedIndex].key;
                // 优化：在 Windows 上，不仅退出页面要屏蔽，进入页面在动画完成前也应屏蔽
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(Tween<Offset>(
                      begin: isIncoming ? const Offset(0, 0.05) : const Offset(0, -0.05),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeOutCubic))),
                    child: ExcludeSemantics(
                      excluding: !animation.isCompleted,
                      child: child,
                    ),
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

  Future<void> _handlePostAction(BuildContext context) async {
    final authState = ref.read(authServiceProvider);
    final hasMisskeyAccount = authState.maybeWhen(
      data: (accounts) => accounts.any((a) => a.platform == 'misskey'),
      orElse: () => false,
    );

    if (hasMisskeyAccount) {
      if (!context.mounted) return;
      showDialog(context: context, builder: (context) => const MisskeyPostPage());
    } else {
      final String soundPath = switch (context.locale.languageCode) {
        'zh' => 'sounds/SpeechNoti/PleaseLogin-zh.wav',
        'en' => 'sounds/SpeechNoti/PleaseLogin-en.wav',
        'ja' => 'sounds/SpeechNoti/PleaseLogin-ja.wav',
        _ => 'sounds/SpeechNoti/PleaseLogin-default.wav',
      };
      await ref.read(audioEngineProvider).playAsset(soundPath);
      if (mounted) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('misskey_page_please_login'.tr()), behavior: SnackBarBehavior.floating),
        );
        context.go('/profile');
      }
    }
  }

  Widget _buildNoAccountState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 80, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 24),
            Text('misskey_page_no_account_title'.tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('misskey_page_no_account_subtitle'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            FilledButton.icon(onPressed: () => context.go('/profile'), icon: const Icon(Icons.login), label: Text('misskey_page_login_now'.tr())),
          ],
        ),
      ),
    );
  }
}

/// 简要的在线人数统计
class _OnlineUsersBrief extends ConsumerWidget {
  const _OnlineUsersBrief();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ref.watch(misskeyOnlineUsersProvider).when(
      data: (count) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
          ).animate(onPlay: (controller) => controller.repeat())
           .scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.4, 1.4), curve: Curves.easeInOut)
           .then().scale(duration: 1.seconds, begin: const Offset(1.4, 1.4), end: const Offset(1, 1)),
          const SizedBox(width: 6),
          Text(count.toString(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
        ],
      ),
      loading: () => const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
