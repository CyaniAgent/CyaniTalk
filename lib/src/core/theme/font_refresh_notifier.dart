import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'font_refresh_notifier.g.dart';

/// 字体刷新状态管理器
/// 用于触发全局字体更新
@Riverpod(keepAlive: true)
class FontRefreshNotifier extends _$FontRefreshNotifier {
  @override
  bool build() => false;

  /// 触发字体更新
  void triggerRefresh() {
    state = !state; // 切换状态以触发重建
  }
}

/// 全局字体刷新器
class GlobalFontRefresher extends StatefulWidget {
  final Widget child;

  const GlobalFontRefresher({super.key, required this.child});

  @override
  State<GlobalFontRefresher> createState() => _GlobalFontRefresherState();

  /// 静态方法，用于触发全局字体刷新
  static void refresh(BuildContext context) {
    final provider = context.findRootAncestorStateOfType<_GlobalFontRefresherState>();
    provider?._triggerRefresh();
  }
}

class _GlobalFontRefresherState extends State<GlobalFontRefresher> {
  int _refreshKey = 0;

  void _triggerRefresh() {
    if (mounted) {
      setState(() {
        _refreshKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(_refreshKey),
      child: widget.child,
    );
  }
}