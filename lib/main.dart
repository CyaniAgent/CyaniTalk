// CyaniTalk应用程序的主入口文件
//
// 该文件包含应用程序的启动逻辑，负责初始化Flutter应用并运行主组件。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';

/// 应用程序的入口点
///
/// 初始化Riverpod的ProviderScope并运行CyaniTalkApp组件，
/// 这是应用程序的根组件。
void main() {
  runApp(const ProviderScope(child: CyaniTalkApp()));
}
