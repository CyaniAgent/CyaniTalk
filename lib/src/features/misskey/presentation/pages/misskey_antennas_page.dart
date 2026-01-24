// Misskey天线页面
//
// 该文件包含MisskeyAntennasPage组件，用于显示Misskey的天线列表。
import 'package:flutter/material.dart';

/// Misskey天线页面组件
///
/// 显示用户创建的天线列表，每个天线包含关键词和匹配规则。
class MisskeyAntennasPage extends StatelessWidget {
  /// 创建一个新的MisskeyAntennasPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyAntennasPage({super.key});

  /// 构建天线页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个显示天线列表的ListView.builder组件
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.satellite_alt),
            title: Text('Antenna ${index + 1}'),
            subtitle: Text('Keywords: flutter, dart, misskey (Match all)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );
      },
    );
  }
}