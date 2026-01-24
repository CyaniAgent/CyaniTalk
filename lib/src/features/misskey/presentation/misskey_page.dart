// Misskey功能的主页面
//
// 该文件包含MisskeyPage组件，是Misskey功能模块的主入口，
// 管理不同Misskey页面的切换和导航。
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/search/global_search_delegate.dart';
import 'widgets/misskey_drawer.dart';
import 'pages/misskey_timeline_page.dart';
import 'pages/misskey_notes_page.dart';
import 'pages/misskey_antennas_page.dart';
import 'pages/misskey_channels_page.dart';
import 'pages/misskey_explore_page.dart';
import 'pages/misskey_follow_requests_page.dart';
import 'pages/misskey_announcements_page.dart';
import 'pages/misskey_post_page.dart';

/// Misskey功能模块的主页面组件
///
/// 负责管理不同Misskey页面的切换，包含侧边栏导航、顶部导航栏和浮动操作按钮。
class MisskeyPage extends StatefulWidget {
  /// 创建一个新的MisskeyPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyPage({super.key});

  /// 创建MisskeyPage的状态管理对象
  @override
  State<MisskeyPage> createState() => _MisskeyPageState();
}

/// MisskeyPage的状态管理类
class _MisskeyPageState extends State<MisskeyPage> {
  /// 当前选中的页面索引
  int _selectedIndex = 0;

  /// 所有可用的Misskey页面列表
  final List<Widget> _pages = const [
    MisskeyTimelinePage(key: ValueKey('timeline')),
    MisskeyNotesPage(key: ValueKey('notes')),
    MisskeyAntennasPage(key: ValueKey('antennas')),
    MisskeyChannelsPage(key: ValueKey('channels')),
    MisskeyExplorePage(key: ValueKey('explore')),
    MisskeyFollowRequestsPage(key: ValueKey('follow_requests')),
    MisskeyAnnouncementsPage(key: ValueKey('announcements')),
  ];

  /// 对应页面的标题列表
  final List<String> _titles = const [
    'Timeline',
    'Notes',
    'Antennas',
    'Channels',
    'Explore',
    'Follow Requests',
    'Announcements',
  ];

  /// 构建Misskey主页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回包含侧边栏、顶部导航栏和内容区域的Scaffold组件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MisskeyDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const MisskeyPostPage(),
          );
        },
        child: const Icon(Icons.edit),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(_titles[_selectedIndex]),
              centerTitle: true,
              floating: true,
              pinned: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.widgets_outlined),
                  tooltip: 'Widgets',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Misskey Widgets opened')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Global Search',
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: GlobalSearchDelegate(),
                    );
                  },
                ),
              ],
            ),
          ];
        },
        body: AnimatedSwitcher(
          duration: 400.ms,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          child: _pages[_selectedIndex],
        ),
      ),
    );
  }
}
