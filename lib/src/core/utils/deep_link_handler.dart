import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '/src/core/core.dart';

/// MiAuth Deep Link 回调解析结果
class MiAuthDeepLinkResult {
  /// MiAuth 会话 ID
  final String session;

  /// Misskey 实例主机地址
  final String host;

  const MiAuthDeepLinkResult({required this.session, required this.host});

  @override
  String toString() =>
      'MiAuthDeepLinkResult(session: $session, host: $host)';
}

/// Deep Link 全局处理器（单例）
///
/// 职责：
/// 1. 在 Windows 上注册 `nyachi-app://` URL 协议（非打包模式）
/// 2. 监听 app_links 的 URI 事件流
/// 3. 解析 MiAuth 回调 URL，通知认证流程
///
/// 使用方式：
/// ```dart
/// // 应用启动时初始化
/// DeepLinkHandler.instance.initialize();
///
/// // 监听 MiAuth 回调
/// DeepLinkHandler.instance.onMiAuthCallback = (result) { ... };
/// ```
class DeepLinkHandler {
  DeepLinkHandler._();

  static final DeepLinkHandler instance = DeepLinkHandler._();

  /// 自定义 URL Scheme
  static const String customScheme = 'nyachi-app';

  AppLinks? _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// MiAuth 回调触发器
  void Function(MiAuthDeepLinkResult result)? onMiAuthCallback;

  bool _initialized = false;

  /// 初始化 Deep Link 处理器
  ///
  /// - 在 Windows 上注册 URL 协议（非 debug 模式）
  /// - 启动 URI 监听
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    logger.info('DeepLinkHandler: 初始化中...');

    // Windows: 注册自定义 URL 协议到系统注册表
    if (Platform.isWindows && !kDebugMode) {
      await _registerWindowsProtocol();
    }

    // 创建 AppLinks 单例并监听
    _appLinks = AppLinks();

    // 获取初始链接（冷启动时由 OS 传入）
    try {
      final initialUri = await _appLinks?.getInitialLink();
      if (initialUri != null) {
        logger.info('DeepLinkHandler: 冷启动链接: $initialUri');
        _handleUri(initialUri);
      }
    } catch (e) {
      logger.warning('DeepLinkHandler: 获取初始链接失败: $e');
    }

    // 监听后续链接（热启动/前台时）
    _linkSubscription = _appLinks?.uriLinkStream.listen(
      (uri) {
        logger.info('DeepLinkHandler: 收到链接: $uri');
        _handleUri(uri);
      },
      onError: (e) {
        logger.error('DeepLinkHandler: 链接监听错误: $e');
      },
    );

    logger.info('DeepLinkHandler: 初始化完成');
  }

  /// 处理接收到的 URI
  void _handleUri(Uri uri) {
    logger.debug('DeepLinkHandler: 解析 URI — scheme=${uri.scheme}, '
        'host=${uri.host}, path=${uri.path}, query=${uri.queryParameters}');

    // 仅处理 nyachi-app:// scheme
    if (uri.scheme != customScheme) {
      logger.debug(
          'DeepLinkHandler: 忽略非 $customScheme scheme: ${uri.scheme}');
      return;
    }

    // 处理 MiAuth 回调: nyachi-app://miauth?session=...&host=...
    if (uri.host == 'miauth') {
      final session = uri.queryParameters['session'];
      final host = uri.queryParameters['host'];

      if (session == null || host == null) {
        logger.warning('DeepLinkHandler: MiAuth 回调缺少参数 '
            '(session=$session, host=$host)');
        return;
      }

      logger.info('DeepLinkHandler: MiAuth 回调解析成功 — '
          'session=$session, host=$host');

      final result = MiAuthDeepLinkResult(session: session, host: host);
      onMiAuthCallback?.call(result);
      return;
    }

    logger.debug('DeepLinkHandler: 未知 host: ${uri.host}');
  }

  /// 在 Windows 注册表中注册 nyachi-app:// URL 协议
  ///
  /// 使用 reg.exe 命令行操作，无需额外依赖。
  /// 如果协议已注册则跳过。
  Future<void> _registerWindowsProtocol() async {
    try {
      // 检查是否已注册
      final checkResult = await Process.run('reg', [
        'query',
        'HKCU\\Software\\Classes\\$customScheme',
        '/ve',
      ]);

      if (checkResult.exitCode == 0) {
        logger.debug('DeepLinkHandler: Windows 协议已注册，跳过');
        return;
      }

      final appPath = Platform.resolvedExecutable;

      // 创建协议根键
      await Process.run('reg', [
        'add',
        'HKCU\\Software\\Classes\\$customScheme',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        'URL:Protocol',
        '/f',
      ]);

      // 设置 URL Protocol 标记
      await Process.run('reg', [
        'add',
        'HKCU\\Software\\Classes\\$customScheme',
        '/v',
        'URL Protocol',
        '/t',
        'REG_SZ',
        '/d',
        '',
        '/f',
      ]);

      // 创建 shell\open\command 子键
      await Process.run('reg', [
        'add',
        'HKCU\\Software\\Classes\\$customScheme\\shell\\open\\command',
        '/ve',
        '/t',
        'REG_SZ',
        '/d',
        '"$appPath" "%1"',
        '/f',
      ]);

      logger.info('DeepLinkHandler: Windows 协议注册成功');
    } catch (e) {
      logger.warning('DeepLinkHandler: Windows 协议注册失败（非致命）: $e');
    }
  }

  /// 清理资源
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _initialized = false;
    logger.info('DeepLinkHandler: 已清理');
  }
}
