import 'dart:async';
import 'dart:io';

import '/src/core/utils/logger.dart';

/// MiAuth 本地 HTTP 服务器回调结果
class MiAuthLocalCallbackResult {
  final String session;
  final String host;

  const MiAuthLocalCallbackResult({
    required this.session,
    required this.host,
  });
}

/// 桌面端 MiAuth 本地 HTTP 服务器
///
/// 在桌面端启动一个临时 HTTP 服务器，监听随机端口，
/// 接收 Misskey 服务器的 MiAuth 回调。
///
/// 使用方式：
/// ```dart
/// final server = MiAuthLocalServer();
/// final callbackUrl = await server.start();
/// // callbackUrl = http://127.0.0.1:12345/miauth
/// // 将此 URL 作为 MiAuth 的 callback 参数
/// // ...
/// await server.stop();
/// ```
class MiAuthLocalServer {
  HttpServer? _server;
  int? _port;
  Completer<MiAuthLocalCallbackResult>? _completer;
  StreamSubscription<HttpRequest>? _subscription;

  /// 服务器是否正在运行
  bool get isRunning => _server != null;

  /// 回调端口
  int? get port => _port;

  /// 启动本地 HTTP 服务器，返回回调 URL 的基础部分
  ///
  /// 返回格式: `http://127.0.0.1:{port}/miauth`
  /// 完整的 MiAuth callback 参数应为: `{baseUrl}?session={session}&host={host}`
  Future<String> start() async {
    if (_server != null) {
      throw StateError('MiAuthLocalServer already running');
    }

    _completer = Completer<MiAuthLocalCallbackResult>();

    // 绑定到随机端口
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _port = _server!.port;

    logger.info('MiAuthLocalServer: 启动于 http://127.0.0.1:$_port');

    _subscription = _server!.listen(_handleRequest);

    return 'http://127.0.0.1:$_port/miauth';
  }

  /// 等待回调完成
  ///
  /// 返回 [MiAuthLocalCallbackResult]，包含 session 和 host
  Future<MiAuthLocalCallbackResult> waitForCallback({
    Duration timeout = const Duration(seconds: 90),
  }) async {
    if (_completer == null) {
      throw StateError('MiAuthLocalServer not started');
    }

    return _completer!.future.timeout(
      timeout,
      onTimeout: () {
        throw TimeoutException('MiAuthLocalServer: 等待回调超时');
      },
    );
  }

  /// 处理 HTTP 请求
  void _handleRequest(HttpRequest request) {
    final uri = request.uri;
    logger.info(
      'MiAuthLocalServer: 收到请求 ${request.method} ${uri.path}',
    );

    // 仅处理 /miauth 路径
    if (uri.path != '/miauth') {
      _sendResponse(request, 404, 'Not Found');
      return;
    }

    final session = uri.queryParameters['session'];
    final host = uri.queryParameters['host'];

    if (session == null || host == null) {
      logger.warning(
        'MiAuthLocalServer: 缺少参数 session=$session, host=$host',
      );
      _sendResponse(request, 400, 'Missing parameters');
      return;
    }

    logger.info(
      'MiAuthLocalServer: 回调成功 — session=$session, host=$host',
    );

    // 返回成功页面
    _sendAuthCompletePage(request, session, host);

    // 完成回调
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(MiAuthLocalCallbackResult(
        session: session,
        host: host,
      ));
    }
  }

  /// 发送认证完成页面
  void _sendAuthCompletePage(
    HttpRequest request,
    String session,
    String host,
  ) {
    try {
      final response = request.response;
      response.statusCode = HttpStatus.ok;
      response.headers.contentType = ContentType.html;

      final htmlContent = _getAuthCompleteHtml(session, host);
      response.write(htmlContent);
      response.close();
    } catch (e) {
      logger.error('MiAuthLocalServer: 发送响应失败: $e');
    }
  }

  /// 发送 HTTP 响应
  void _sendResponse(HttpRequest request, int statusCode, String message) {
    try {
      final response = request.response;
      response.statusCode = statusCode;
      response.headers.contentType = ContentType.text;
      response.write(message);
      response.close();
    } catch (e) {
      logger.error('MiAuthLocalServer: 发送响应失败: $e');
    }
  }

  /// 获取认证完成页面的 HTML 内容
  String _getAuthCompleteHtml(String session, String host) {
    // Deep Link 跳转地址
    final deepLinkUrl =
        'nyachi-app://miauth?session=$session&host=$host';

    return '''
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Nyachi - 授权完成</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .card {
      background: white;
      border-radius: 24px;
      padding: 48px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
      text-align: center;
      max-width: 400px;
      width: 90%;
    }
    .icon {
      width: 80px;
      height: 80px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 24px;
    }
    .icon svg {
      width: 40px;
      height: 40px;
      fill: white;
    }
    h1 {
      font-size: 24px;
      color: #333;
      margin-bottom: 12px;
    }
    p {
      font-size: 16px;
      color: #666;
      line-height: 1.6;
    }
    .link {
      color: #667eea;
      text-decoration: none;
      font-weight: 500;
    }
    .link:hover {
      text-decoration: underline;
    }
    .session-id {
      margin-top: 20px;
      padding: 10px 14px;
      background: #f5f5f5;
      border-radius: 8px;
      font-family: 'SF Mono', 'Consolas', 'Monaco', monospace;
      font-size: 12px;
      color: #999;
      word-break: break-all;
      user-select: all;
    }
    .session-label {
      margin-top: 20px;
      font-size: 12px;
      color: #aaa;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
      </svg>
    </div>
    <h1>授权完成！</h1>
    <p>
      如果无法跳转到 App，请
      <a class="link" href="$deepLinkUrl">点此手动跳转</a>
    </p>
    <div class="session-label">Session ID</div>
    <div class="session-id">$session</div>
  </div>
</body>
</html>
''';
  }

  /// 停止服务器并释放资源
  Future<void> stop() async {
    logger.info('MiAuthLocalServer: 正在停止...');

    _subscription?.cancel();
    _subscription = null;

    await _server?.close(force: true);
    _server = null;
    _port = null;

    // 如果还有未完成的 Future，抛出异常
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(
        StateError('MiAuthLocalServer stopped before callback'),
      );
    }
    _completer = null;

    logger.info('MiAuthLocalServer: 已停止');
  }
}
