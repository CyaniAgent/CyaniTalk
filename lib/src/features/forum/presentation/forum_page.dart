// Flarum论坛功能页面
//
// 该文件包含ForumPage组件，用于显示Flarum论坛功能的入口界面。
import 'package:flutter/material.dart';

/// Flarum论坛功能的主页面组件
///
/// 显示Flarum论坛功能的入口界面，包含标题栏和中心文本。
class ForumPage extends StatelessWidget {
  /// 创建一个新的ForumPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const ForumPage({super.key});

  /// 构建Flarum论坛页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含标题栏和中心文本的Scaffold组件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flarum')),
      body: const Center(child: Text('Flarum Page')),
    );
  }
}
