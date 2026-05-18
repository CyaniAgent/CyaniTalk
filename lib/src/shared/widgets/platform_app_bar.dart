import 'dart:io';

import 'package:flutter/material.dart';

/// 桌面端 AppBar 显隐帮助函数
///
/// 在桌面端（Windows/Linux/macOS）返回 null，不显示页面内 AppBar
/// 在移动端返回传入的 AppBar 组件
///
/// [appBar] - 要显示的 AppBar 组件
///
/// 返回：移动端返回 [appBar]，桌面端返回 null
AppBar? desktopNullAppBar(AppBar? appBar) {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return null;
  }
  return appBar;
}

/// 根页面 AppBar 显隐帮助函数
///
/// 所有平台都返回传入的 AppBar
/// 用于 Misskey、云盘、聊天、消息、我 这五个根导航页面
///
/// [appBar] - 要显示的 AppBar 组件
///
/// 返回：始终返回 [appBar]
AppBar? rootAppBar(AppBar? appBar) {
  return appBar;
}
