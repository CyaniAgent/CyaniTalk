// Misskey功能的主页面
//
// 该文件包含MisskeyPage组件，是Misskey功能模块的主入口，
// 管理不同Misskey页面的切换和导航。
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/core/utils/logger.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/features/misskey/presentation/widgets/misskey_drawer.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import '/src/features/misskey/presentation/pages/misskey_timeline_page.dart';
import '/src/features/misskey/presentation/pages/misskey_notes_page.dart';
import '/src/features/misskey/presentation/pages/misskey_antennas_page.dart';
import '/src/features/misskey/presentation/pages/misskey_channels_page.dart';
import '/src/features/misskey/presentation/pages/misskey_explore_page.dart';
import '/src/features/misskey/presentation/pages/misskey_follow_requests_page.dart';
import '/src/features/misskey/presentation/pages/misskey_announcements_page.dart';
import '/src/features/misskey/presentation/pages/misskey_aiscript_console_page.dart';
import '/src/features/misskey/presentation/pages/misskey_post_page.dart';

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
  /// 当前选中的页面索引
  int _selectedIndex = 0;

  @override
  void dispose() {
    super.dispose();
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

    return Scaffold(
      drawer: MisskeyDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          logger.info(
            'MisskeyPage: Navigation drawer selected index: $index (${_titles[index]})',
          );
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: selectedAccountAsync.when(
        data: (account) {
          if (account != null) {
            return FloatingActionButton(
              heroTag: 'misskey_fab',
              onPressed: () async {
                logger.info('MisskeyPage: Floating action button pressed');
                logger.info('MisskeyPage: Opening post dialog (user logged in)');
                showDialog(
                  context: context,
                  builder: (context) => const MisskeyPostPage(),
                );
              },
              child: const Icon(Icons.edit),
            );
          }
          return null;
        },
        loading: () => null,
        error: (err, stack) => null,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _titles[_selectedIndex],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_selectedIndex == 0) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: ref
                            .watch(misskeyOnlineUsersProvider)
                            .when(
                              data: (count) => Text(
                                'misskey_online_users'.tr(
                                  namedArgs: {'count': count.toString()},
                                ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ).animate().fadeIn().scale(),
                              loading: () => const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              error: (error, stack) => const SizedBox.shrink(),
                            ),
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
                  icon: const Icon(Icons.widgets_outlined),
                  tooltip: 'misskey_page_widgets'.tr(),
                  onPressed: () {
                    logger.info('MisskeyPage: Widgets button pressed');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'misskey_page_misskey_widgets_opened'.tr(),
                        ),
                      ),
                    );
                  },
                ),
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
              duration: 400.ms,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _pages[_selectedIndex],
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
            ).animate().scale(delay: 200.ms).fadeIn(),
            const SizedBox(height: 24),
            Text(
              'misskey_page_no_account_title'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ).animate().slideY(begin: 0.2, curve: Curves.easeOutQuad).fadeIn(),
            const SizedBox(height: 12),
            Text(
              'misskey_page_no_account_subtitle'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ).animate().slideY(begin: 0.3, curve: Curves.easeOutQuad).fadeIn(),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/profile'),
              icon: const Icon(Icons.login),
              label: Text('misskey_page_login_now'.tr()),
            ).animate().scale(delay: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
