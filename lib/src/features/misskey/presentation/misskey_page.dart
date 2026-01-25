// Misskey功能的主页面
//
// 该文件包含MisskeyPage组件，是Misskey功能模块的主入口，
// 管理不同Misskey页面的切换和导航。
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/services/search/global_search_delegate.dart';
import '../../auth/application/auth_service.dart';
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

  /// 音频播放器实例
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
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
  ];

  /// 对应页面的标题列表
  final List<String> _titles = [
    'misskey_page_timeline'.tr(),
    'misskey_page_notes'.tr(),
    'misskey_page_antennas'.tr(),
    'misskey_page_channels'.tr(),
    'misskey_page_explore'.tr(),
    'misskey_page_follow_requests'.tr(),
    'misskey_page_announcements'.tr(),
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
        onPressed: () async {
          // 检查是否已登录 Misskey
          final authState = ref.read(authServiceProvider);
          final hasMisskeyAccount = authState.maybeWhen(
            data: (accounts) => accounts.any((a) => a.platform == 'misskey'),
            orElse: () => false,
          );

          if (hasMisskeyAccount) {
            // 已登录，打开发布窗口
            showDialog(
              context: context,
              builder: (context) => const MisskeyPostPage(),
            );
          } else {
            // 未登录，播放提示音并跳转到登录页面
            try {
              await _audioPlayer.play(
                AssetSource('sounds/SpeechNoti/PleaseLogin-default.wav'),
              );
            } catch (e) {
              debugPrint('Error playing sound: $e');
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('misskey_page_please_login'.tr()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // 跳转到 Profile 页面进行登录
              context.go('/profile');
            }
          }
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
                  tooltip: 'misskey_page_widgets'.tr(),
                  onPressed: () {
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
                  scale: Tween<double>(
                    begin: 0.95,
                    end: 1.0,
                  ).animate(animation),
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
