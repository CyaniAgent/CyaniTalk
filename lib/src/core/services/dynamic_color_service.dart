import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';

/// 跨平台动态取色服务
///
/// - Windows: 通过原生 WM_DWMCOLORIZATIONCOLORCHANGED 消息实时监听系统主题色变化
/// - Android 12+: 优先通过 CorePalette 获取系统动态色（还原度最高）
/// - macOS/Linux/其他: App 回到前台时轮询对比
/// - 提供 [accentColor] ValueNotifier 供主题系统监听
class DynamicColorService extends WidgetsBindingObserver {
  DynamicColorService._();
  static final instance = DynamicColorService._();

  /// MethodChannel — 接收 Windows 原生推送的强调色变化
  static const _channel = MethodChannel('com.Nyachi/accent_color');

  /// 当前系统强调色（null 表示平台不支持或尚未获取）
  final ValueNotifier<Color?> accentColor = ValueNotifier<Color?>(null);

  /// 当前完整的动态 ColorScheme（light）
  ColorScheme? lightScheme;

  /// 当前完整的动态 ColorScheme（dark）
  ColorScheme? darkScheme;

  Color? _lastKnownColor;
  bool _initialized = false;

  /// 初始化服务：注册监听器并获取初始颜色
  ///
  /// 仅在 Windows 平台生效。其他平台无操作。
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!Platform.isWindows) return;

    // 注册生命周期观察者（Windows 回到前台时轮询兜底）
    WidgetsBinding.instance.addObserver(this);

    // 监听原生颜色变化推送
    _channel.setMethodCallHandler(_onMethodCall);

    // 获取初始颜色
    await _fetchAccentColor();
  }

  /// 销毁服务
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _channel.setMethodCallHandler(null);
  }

  /// 处理来自 Windows 原生的 MethodChannel 调用
  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == 'onAccentColorChanged') {
      final argb = call.arguments as int?;
      if (argb != null) {
        final newColor = Color(argb);
        _updateColor(newColor);
      }
    }
  }

  /// 从系统获取强调色（仅 Windows）
  ///
  /// 使用 DynamicColorPlugin 获取初始 accent color，
  /// 后续变化由原生 MethodChannel 推送。
  Future<void> _fetchAccentColor() async {
    if (!Platform.isWindows) return;

    // Android 12+：优先通过 CorePalette 获取系统动态色（还原度最高）
    // iOS：该 dynamic_color 版本未实现，返回 null/异常后走桌面通道
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      if (corePalette != null) {
        // 以系统主色调（tone 40）作为种子色，由 _updateColor 生成 ColorScheme
        _updateColor(Color(corePalette.primary.get(40)));
        return;
      }
    } catch (e) {
      // 非 Android 平台 getCorePalette 不受支持，回退到 getAccentColor
    }

    // macOS / Windows / Linux：获取系统强调色
    try {
      final color = await DynamicColorPlugin.getAccentColor();
      if (color != null) {
        _updateColor(color);
      }
    } catch (e) {
      debugPrint('DynamicColorService: failed to fetch accent color — $e');
    }
  }

  /// 更新颜色并重建 ColorScheme
  void _updateColor(Color color) {
    if (_lastKnownColor != null && _lastKnownColor!.toARGB32() == color.toARGB32()) {
      return;
    }
    _lastKnownColor = color;

    lightScheme = ColorScheme.fromSeed(seedColor: color, brightness: Brightness.light);
    darkScheme = ColorScheme.fromSeed(seedColor: color, brightness: Brightness.dark);

    accentColor.value = color;

    debugPrint('DynamicColorService: accent color updated — #${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}');
  }

  // ── WidgetsBindingObserver: App 回到前台时轮询兜底 ──────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isWindows) {
      _fetchAccentColor();
    }
  }
}
