import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import '../../../core/api/flarum_api.dart';
import '../../../core/navigation/navigation.dart';
import '../../../core/navigation/sub_navigation_notifier.dart';
import '../../flarum/presentation/pages/flarum_discussion_page.dart';
import '../../flarum/presentation/pages/flarum_tags_page.dart';
import '../../flarum/presentation/pages/flarum_notifications_page.dart';
import '../../auth/application/auth_service.dart';
import '../../../shared/widgets/login_reminder.dart';

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
  Widget build(BuildContext context) {
    final account = ref.watch(selectedFlarumAccountProvider).asData?.value;
    final selectedIndex = ref.watch(forumSubIndexProvider);
    final flarumApi = FlarumApi();
    final hasEndpoint = flarumApi.baseUrl != null;

    if (account == null && !hasEndpoint) {
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
}
