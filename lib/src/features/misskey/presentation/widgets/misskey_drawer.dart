// Misskey侧边栏导航组件
//
// 该文件包含MisskeyDrawer组件，用于显示Misskey功能模块的侧边栏导航菜单。
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Misskey功能模块的侧边栏导航组件
///
/// 显示Misskey各功能页面的导航选项，允许用户切换不同的页面。
class MisskeyDrawer extends StatelessWidget {
  /// 当前选中的导航项索引
  final int selectedIndex;
  
  /// 导航项选中时的回调函数
  final ValueChanged<int> onDestinationSelected;

  /// 创建一个新的MisskeyDrawer实例
  ///
  /// [selectedIndex] - 当前选中的导航项索引
  /// [onDestinationSelected] - 导航项选中时的回调函数
  const MisskeyDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  /// 构建Misskey侧边栏导航的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个NavigationDrawer组件，包含所有Misskey功能导航项
  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        onDestinationSelected(index);
        Navigator.of(context).maybePop(); // 安全地关闭侧边栏
      },
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            'misskey_drawer_misskey_menu'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.timeline_outlined),
          selectedIcon: Icon(Icons.timeline),
          label: Text('misskey_drawer_timeline'.tr()),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.collections_bookmark_outlined),
          selectedIcon: Icon(Icons.collections_bookmark),
          label: Text('misskey_drawer_clips'.tr()),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.satellite_alt_outlined),
          selectedIcon: Icon(Icons.satellite_alt),
          label: Text('misskey_drawer_antennas'.tr()),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.hub_outlined),
          selectedIcon: Icon(Icons.hub),
          label: Text('misskey_drawer_channels'.tr()),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: Text('misskey_drawer_explore'.tr()),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.person_add_outlined),
          selectedIcon: Icon(Icons.person_add),
          label: Text('misskey_drawer_follow_requests'.tr()),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.campaign_outlined),
          selectedIcon: Icon(Icons.campaign),
          label: Text('misskey_drawer_announcements'.tr()),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.terminal_outlined),
          selectedIcon: Icon(Icons.terminal),
          label: Text('misskey_drawer_aiscript_console'.tr()),
        ),
      ],
    );
  }
}
