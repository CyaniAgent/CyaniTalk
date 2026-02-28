import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import '/src/features/flarum/application/flarum_providers.dart';
import '/src/core/navigation/navigation.dart';
import '/src/core/navigation/sub_navigation_notifier.dart';
import '/src/features/flarum/presentation/pages/flarum_discussion_page.dart';
import '/src/features/flarum/presentation/pages/flarum_tags_page.dart';
import '/src/features/flarum/presentation/pages/flarum_notifications_page.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/shared/widgets/login_reminder.dart';

class ForumPage extends ConsumerStatefulWidget {
  const ForumPage({super.key});

  @override
  ConsumerState<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends ConsumerState<ForumPage> {
  final List<Widget> _pages = const [
    FlarumDiscussionPage(key: ValueKey('discussion')),
    FlarumTagsPage(key: ValueKey('tags')),
    FlarumNotificationsPage(key: ValueKey('notifications')),
  ];

  final List<String> _titles = const ['Discussions', 'Tags', 'Notifications'];

  @override
  void initState() {
    super.initState();
    // 初始刷新子页面数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final selectedIndex = ref.read(forumSubIndexProvider);
        _refreshCurrentSubPage(selectedIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. 获取当前选中的 Flarum 账户
    final accountAsync = ref.watch(selectedFlarumAccountProvider);
    final account = accountAsync.asData?.value;
    
    final selectedIndex = ref.watch(forumSubIndexProvider);
    final flarumApi = ref.watch(flarumApiProvider);

    // 2. 核心逻辑：如果没有登录任何账户，或者 API 的端点与当前账户不一致
    // 注意：我们将不再依赖 flarumApi 的隐藏默认值
    final bool isLoggedOut = account == null;
    final bool isEndpointMismatch = account != null && 
        (flarumApi.baseUrl == null || !flarumApi.baseUrl!.contains(account.host));

    if (isLoggedOut || isEndpointMismatch) {
      // 如果账户存在但 API 没跟上，尝试在后台同步 API 端点（这种情况通常发生在刚刚登录或切换账户时）
      if (account != null && isEndpointMismatch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          flarumApi.setBaseUrl('https://${account.host}');
          flarumApi.setToken(account.token, userId: account.id.split('@').first);
          if (mounted) setState(() {}); // 触发重绘以进入正常页面
        });
      }

      return Scaffold(
        appBar: AppBar(
          leading: Breakpoints.small.isActive(context)
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => ref
                      .read(navigationControllerProvider.notifier)
                      .openDrawer(),
                )
              : null,
          title: Text('forum_page_title'.tr()),
          centerTitle: true,
        ),
        body: LoginReminder(
          title: 'forum_page_not_connected'.tr(),
          message: 'forum_page_please_connect'.tr(),
          icon: Icons.forum_outlined,
        ),
      );
    }

    // Auto-refresh when switching sub-tabs
    ref.listen(forumSubIndexProvider, (previous, next) {
      _refreshCurrentSubPage(next);
    });

    return Scaffold(
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
              title: Text(_titles[selectedIndex]),
              centerTitle: true,
              floating: true,
              pinned: true,
              snap: true,
            ),
          ];
        },
        body: AnimatedSwitcher(
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
        ),
      ),
    );
  }

  void _refreshCurrentSubPage(int index) {
    if (!mounted) return;
    
    // 只有在已登录且端点正确的情况下才执行刷新
    final account = ref.read(selectedFlarumAccountProvider).value;
    if (account == null) return;

    switch (index) {
      case 0:
        ref.invalidate(discussionsProvider);
        break;
      case 1:
        ref.invalidate(forumInfoProvider);
        break;
      case 2:
        ref.invalidate(flarumNotificationsProvider);
        break;
    }
  }
}
