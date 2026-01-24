// 云存储功能页面
//
// 该文件包含CloudPage组件，用于显示云存储功能的入口界面。
import 'package:flutter/material.dart';

/// 云存储功能的主页面组件
///
/// 显示云存储功能的入口界面，包含标题栏和中心文本。
class CloudPage extends StatelessWidget {
  /// 创建一个新的CloudPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const CloudPage({super.key});

  /// 构建云存储页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含标题栏和中心文本的Scaffold组件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud')),
      body: const Center(child: Text('Cloud Page')),
    );
  }
}
