import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/src/core/navigation/navigation.dart';
import '/src/core/navigation/sub_navigation_notifier.dart';
import '/src/core/services/audio_engine.dart';
import '/src/core/theme/desktop_semantic_colors.dart';
import '/src/core/utils/logger.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import '/src/features/misskey/application/misskey_notifications_notifier.dart';
import 'pages/misskey_aiscript_console_page.dart';
import 'pages/misskey_announcements_page.dart';
import 'pages/misskey_antennas_page.dart';
import 'pages/misskey_channels_page.dart';
import 'pages/misskey_explore_page.dart';
import 'pages/misskey_follow_requests_page.dart';
import 'pages/misskey_notes_page.dart';
import 'pages/misskey_post_page.dart';
import 'pages/misskey_timeline_page.dart';
import '/src/shared/extensions/ui_extensions.dart';

class MisskeyPage extends ConsumerStatefulWidget {
  const MisskeyPage({super.key});

  @override
  ConsumerState<MisskeyPage> createState() => _MisskeyPageState();
}

class _MisskeyPageState extends ConsumerState<MisskeyPage>
    with WidgetsBindingObserver {
  String _timelineType = 'Global';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        ref.read(misskeyTimelineProvider(_timelineType).notifier).refresh();
      }
      ref.read(misskeyNotificationsProvider.notifier).refresh();
    } catch (e) {
      logger.warning('MisskeyPage: Background refresh failed: $e');
    }
  }

  void _triggerRefreshIfNecessary(int index) {
    if (index == 0) {
      try {
        ref.read(misskeyTimelineProvider(_timelineType).notifier).refresh();
      } catch (e) {
        logger.warning('MisskeyPage: Manual refresh failed: $e');
      }
    }
  }

  String _timelineLabel(String timelineType) {
    return switch (timelineType) {
      'Local' => 'timeline_local'.tr(),
      'Social' => 'timeline_social'.tr(),
      _ => 'timeline_global'.tr(),
    };
  }

  void _onTimelineTypeChanged(String timelineType) {
    if (timelineType == _timelineType) return;
    setState(() => _timelineType = timelineType);
    ref.read(misskeyTimelineProvider(timelineType).notifier).refresh();
  }

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
    final desktopColors = context.desktopSemanticColors;
    final isTimelineSelected = selectedIndex == 0;

    final pages = [
      MisskeyTimelinePage(
        key: const ValueKey('timeline'),
        timelineType: _timelineType,
      ),
      const MisskeyNotesPage(key: ValueKey('notes')),
      const MisskeyAntennasPage(key: ValueKey('antennas')),
      const MisskeyChannelsPage(key: ValueKey('channels')),
      const MisskeyExplorePage(key: ValueKey('explore')),
      const MisskeyFollowRequestsPage(key: ValueKey('follow_requests')),
      const MisskeyAnnouncementsPage(key: ValueKey('announcements')),
      const MisskeyAiScriptConsolePage(key: ValueKey('aiscript_console')),
    ];

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
              backgroundColor: isTimelineSelected
                  ? desktopColors.timelineBackground
                  : desktopColors.contentBackground,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: Breakpoints.small.isActive(context)
                  ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => ref
                          .read(navigationControllerProvider.notifier)
                          .openDrawer(),
                    )
                  : null,
              title: selectedIndex == 0
                  ? _TimelineTopBar(
                      timelineType: _timelineType,
                      timelineLabel: _timelineLabel(_timelineType),
                      onTimelineTypeChanged: _onTimelineTypeChanged,
                    )
                  : Text(_titles[selectedIndex]),
              titleSpacing: Breakpoints.small.isActive(context) ? 4 : 12,
              centerTitle: false,
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
                final isIncoming = child.key == pages[selectedIndex].key;
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween<Offset>(
                        begin: isIncoming
                            ? const Offset(0, 0.05)
                            : const Offset(0, -0.05),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeOutCubic)),
                    ),
                    child: ExcludeSemantics(
                      excluding: !animation.isCompleted,
                      child: child,
                    ),
                  ),
                );
              },
              child: pages[selectedIndex],
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
      showDialog(
        context: context,
        builder: (context) => const MisskeyPostPage(),
      );
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
        ScaffoldMessenger.of(context).showTopSnackBar(
          SnackBar(
            content: Text('misskey_page_please_login'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
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

class _TimelineTopBar extends ConsumerWidget {
  const _TimelineTopBar({
    required this.timelineType,
    required this.timelineLabel,
    required this.onTimelineTypeChanged,
  });

  final String timelineType;
  final String timelineLabel;
  final ValueChanged<String> onTimelineTypeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    const onlineColor = Color(0xFF16D9C5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          tooltip: 'timeline'.tr(),
          onSelected: onTimelineTypeChanged,
          itemBuilder: (context) => [
            PopupMenuItem(value: 'Global', child: Text('timeline_global'.tr())),
            PopupMenuItem(value: 'Local', child: Text('timeline_local'.tr())),
            PopupMenuItem(value: 'Social', child: Text('timeline_social'.tr())),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${'misskey_page_timeline'.tr()} · $timelineLabel',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        ref
            .watch(misskeyOnlineUsersProvider)
            .when(
              data: (count) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_tethering_rounded,
                    size: 18,
                    color: onlineColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: onlineColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stack) => const SizedBox.shrink(),
            ),
      ],
    );
  }
}
