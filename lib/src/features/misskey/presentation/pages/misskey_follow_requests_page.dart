// Misskey关注请求页面
//
// 该文件包含MisskeyFollowRequestsPage组件，用于显示和处理关注请求。
import 'package:flutter/material.dart';

/// Misskey关注请求页面组件
///
/// 显示用户收到的关注请求列表，并提供接受或拒绝的功能。
class MisskeyFollowRequestsPage extends StatelessWidget {
  /// 创建一个新的MisskeyFollowRequestsPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const MisskeyFollowRequestsPage({super.key});

  /// 构建关注请求页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个显示关注请求列表的ListView.builder组件
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text('Requesting User ${index + 1}'),
          subtitle: const Text('Wants to follow you'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {},
                tooltip: 'Accept',
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {},
                tooltip: 'Reject',
              ),
            ],
          ),
        );
      },
    );
  }
}