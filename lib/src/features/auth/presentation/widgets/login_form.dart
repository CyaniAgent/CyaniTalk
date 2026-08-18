import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:Nyachi/src/shared/widgets/toast_helper.dart';
import 'login_form_components.dart';
import 'package:Nyachi/src/features/auth/application/auth_service.dart';
import 'package:Nyachi/src/features/misskey/application/misskey_streaming_service.dart';
import 'package:Nyachi/src/core/utils/logger.dart';
import 'package:Nyachi/src/core/utils/proxy_detection.dart';
import 'package:Nyachi/src/core/utils/deep_link_handler.dart';

/// 统一的登录表单控件
///
/// 包含两种登录方式：
/// - **MiAuth Direct**：浏览器授权 + 轮询/Deep Link 回调
/// - **MiAuth Token**：手动输入访问令牌，即时验证
class LoginForm extends ConsumerStatefulWidget {
  final bool showPlatformSelection;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onLoginFailed;
  final String? initialHost;
  final bool isBottomSheet;

  const LoginForm({
    super.key,
    this.showPlatformSelection = true,
    this.onLoginSuccess,
    this.onLoginFailed,
    this.initialHost,
    this.isBottomSheet = true,
  });

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  LoginStep _currentStep = LoginStep.loginMethod;
  bool _loading = false;

  final _misskeyHostController = TextEditingController();
  final _tokenHostController = TextEditingController();
  final _tokenController = TextEditingController();

  String? _misskeyHost;
  String? _misskeySession;
  String? _proxyWarning;
  String? _connectivityWarning;

  Timer? _miauthPollTimer;
  bool _previousMiauthState = false;
  Timer? _miauthTimeoutTimer;
  int _consecutiveNetworkErrors = 0;
  bool _isManualChecking = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialHost != null) {
      _misskeyHostController.text = widget.initialHost!;
    }
  }

  @override
  void dispose() {
    _stopMiAuthPolling();
    _cancelMiAuthTimeout();
    _restoreMiAuthLifecycle();
    _unregisterDeepLinkCallback();
    _misskeyHostController.dispose();
    _tokenHostController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  // ── MiAuth Deep Link + 轮询回退 ────────────────────────────────

  void _startMiAuthVerification() {
    _consecutiveNetworkErrors = 0;

    DeepLinkHandler.instance.onMiAuthCallback = _onDeepLinkCallback;
    logger.info('LoginForm: 已注册 Deep Link MiAuth 回调');

    _startMiAuthPolling();

    _cancelMiAuthTimeout();
    _miauthTimeoutTimer = Timer(const Duration(seconds: 90), () {
      if (!mounted) return;
      logger.warning('LoginForm: MiAuth 90 秒超时');
      _stopMiAuthPolling();
      _unregisterDeepLinkCallback();
      _restoreMiAuthLifecycle();
      setState(() => _currentStep = LoginStep.misskeyDirectLogin);
      showToast(
        title: 'MiAuth 认证超时（90 秒），请重试',
        type: ToastificationType.error,
      );
    });
  }

  void _onDeepLinkCallback(MiAuthDeepLinkResult result) {
    if (!mounted) return;
    if (_misskeyHost == null || _misskeySession == null) return;
    if (result.session != _misskeySession) {
      logger.warning('LoginForm: Deep Link session 不匹配，忽略');
      return;
    }
    logger.info('LoginForm: Deep Link MiAuth 回调触发');
    _completeMiAuth(result.host, result.session);
  }

  Future<void> _completeMiAuth(String host, String session) async {
    if (!mounted) return;

    final result = await ref
        .read(authServiceProvider.notifier)
        .completeMiAuthFromDeepLink(host, session);

    if (!mounted) return;

    switch (result) {
      case MiAuthCheckResult.success:
        _stopMiAuthPolling();
        _cancelMiAuthTimeout();
        _unregisterDeepLinkCallback();
        _restoreMiAuthLifecycle();
        widget.onLoginSuccess?.call();
        if (widget.isBottomSheet) Navigator.pop(context);
        break;
      case MiAuthCheckResult.pending:
        logger.debug('LoginForm: Deep Link 回调后 pending，继续轮询');
        break;
      case MiAuthCheckResult.networkError:
        logger.warning('LoginForm: Deep Link 回调后网络错误，轮询将继续');
        if (mounted) {
          showToast(
            title: 'Deep Link 检查失败，正在通过轮询重试...',
            type: ToastificationType.warning,
          );
        }
        break;
    }
  }

  Future<void> _manualCheckMiAuth() async {
    if (_misskeyHost == null || _misskeySession == null) return;
    if (!mounted || _isManualChecking) return;

    setState(() => _isManualChecking = true);
    logger.info('LoginForm: 用户手动触发 MiAuth 检查');

    try {
      final result = await ref
          .read(authServiceProvider.notifier)
          .checkMiAuth(_misskeyHost!, _misskeySession!);

      if (!mounted) return;

      switch (result) {
        case MiAuthCheckResult.success:
          _stopMiAuthPolling();
          _cancelMiAuthTimeout();
          _unregisterDeepLinkCallback();
          _restoreMiAuthLifecycle();
          widget.onLoginSuccess?.call();
          if (widget.isBottomSheet) Navigator.pop(context);
          break;
        case MiAuthCheckResult.pending:
          showToast(
            title: '尚未检测到授权，请在浏览器中完成授权后重试',
            type: ToastificationType.info,
          );
          break;
        case MiAuthCheckResult.networkError:
          showToast(
            title: '网络错误，请检查网络连接后重试',
            type: ToastificationType.warning,
          );
          break;
      }
    } finally {
      if (mounted) setState(() => _isManualChecking = false);
    }
  }

  void _startMiAuthPolling() {
    _miauthPollTimer?.cancel();
    _miauthPollTimer = Timer(const Duration(seconds: 5), () {
      _pollMiAuth();
      _miauthPollTimer = Timer.periodic(
        const Duration(seconds: 8),
        (_) => _pollMiAuth(),
      );
    });
  }

  void _stopMiAuthPolling() {
    _miauthPollTimer?.cancel();
    _miauthPollTimer = null;
  }

  void _cancelMiAuthTimeout() {
    _miauthTimeoutTimer?.cancel();
    _miauthTimeoutTimer = null;
  }

  void _unregisterDeepLinkCallback() {
    if (DeepLinkHandler.instance.onMiAuthCallback != null) {
      DeepLinkHandler.instance.onMiAuthCallback = null;
    }
  }

  Future<void> _pollMiAuth() async {
    if (_misskeyHost == null || _misskeySession == null) return;
    if (!mounted || _isManualChecking) return;

    final result = await ref
        .read(authServiceProvider.notifier)
        .checkMiAuth(_misskeyHost!, _misskeySession!);

    if (!mounted) return;

    switch (result) {
      case MiAuthCheckResult.success:
        _stopMiAuthPolling();
        _cancelMiAuthTimeout();
        _unregisterDeepLinkCallback();
        _restoreMiAuthLifecycle();
        widget.onLoginSuccess?.call();
        if (widget.isBottomSheet) Navigator.pop(context);
        break;
      case MiAuthCheckResult.pending:
        _consecutiveNetworkErrors = 0;
        break;
      case MiAuthCheckResult.networkError:
        _consecutiveNetworkErrors++;
        if (_consecutiveNetworkErrors >= 3) {
          _stopMiAuthPolling();
          final backoffSeconds = math.min(
            8 * math.pow(2, _consecutiveNetworkErrors - 1),
            60,
          ).toInt();
          _miauthPollTimer = Timer(Duration(seconds: backoffSeconds), () {
            if (mounted && _currentStep == LoginStep.misskeyCheckAuth) {
              _pollMiAuth();
              _miauthPollTimer = Timer.periodic(
                Duration(seconds: backoffSeconds),
                (_) => _pollMiAuth(),
              );
            }
          });
        }
        if (_consecutiveNetworkErrors == 8) {
          showToast(
            title: '多次网络错误，建议点击「检查」按钮手动重试',
            type: ToastificationType.warning,
          );
        }
        break;
    }
  }

  void _suppressMiAuthLifecycle() {
    final authNotifier = ref.read(authServiceProvider.notifier);
    _previousMiauthState = authNotifier.isMiAuthInProgress;
    authNotifier.isMiAuthInProgress = true;
    ref.read(misskeyStreamingServiceProvider.notifier).setBackgroundMode(false);
  }

  void _restoreMiAuthLifecycle() {
    final authNotifier = ref.read(authServiceProvider.notifier);
    authNotifier.isMiAuthInProgress = _previousMiauthState;
  }

  // ── 步骤导航 ─────────────────────────────────────────────────────

  void _setStep(LoginStep step) {
    setState(() => _currentStep = step);
  }

  void _back() {
    switch (_currentStep) {
      case LoginStep.loginMethod:
        break;
      case LoginStep.misskeyDirectLogin:
        _setStep(LoginStep.loginMethod);
        break;
      case LoginStep.tokenInstructions:
        _setStep(LoginStep.loginMethod);
        break;
      case LoginStep.tokenInput:
        _setStep(LoginStep.tokenInstructions);
        break;
      case LoginStep.misskeyCheckAuth:
        _stopMiAuthPolling();
        _cancelMiAuthTimeout();
        _unregisterDeepLinkCallback();
        _restoreMiAuthLifecycle();
        _setStep(LoginStep.misskeyDirectLogin);
        break;
    }
  }

  // ── MiAuth Direct 登录 ─────────────────────────────────────────

  Future<void> _startMisskeyAuth() async {
    final host = _misskeyHostController.text.trim();
    if (host.isEmpty) return;

    String displayHost = host;
    if (host.contains('://')) {
      displayHost = host.split('://').last;
    }
    if (displayHost.contains('/')) {
      displayHost = displayHost.split('/').first;
    }

    logger.info('LoginForm: Starting Misskey Direct auth for $displayHost');
    setState(() {
      _loading = true;
      _connectivityWarning = null;
    });
    try {
      // ── 连通性测试：向实例发送 ping 请求，验证网络可达 ──
      final testDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      bool connectivityOk = true;
      try {
        final testResponse = await testDio.post(
          'https://$displayHost/api/ping',
          data: <String, dynamic>{},
        );
        if (testResponse.statusCode != null &&
            testResponse.statusCode! >= 500) {
          logger.warning(
            'LoginForm: 实例返回 5xx: ${testResponse.statusCode}',
          );
          connectivityOk = false;
        }
      } on DioException catch (e) {
        logger.warning(
          'LoginForm: 实例连通性测试失败: ${e.type} - ${e.message}',
        );
        connectivityOk = false;
      }

      if (!connectivityOk) {
        if (mounted) {
          setState(() {
            _loading = false;
            _connectivityWarning =
                'auth_miauth_connectivity_failed'.tr();
            _currentStep = LoginStep.tokenInstructions;
          });
        }
        return;
      }

      // ── 连通性正常，开始 MiAuth 认证 ──
      final proxyList = await detectProxyOrVpn();
      final warning = proxyList.isNotEmpty
          ? '检测到 ${proxyList.join('、')} 服务正在运行，可能影响 MiAuth 登录，建议关闭后重试。'
          : null;

      final session = await ref
          .read(authServiceProvider.notifier)
          .startMiAuth(host);
      if (mounted) {
        setState(() {
          _misskeyHost = host;
          _misskeySession = session;
          _proxyWarning = warning;
          _currentStep = LoginStep.misskeyCheckAuth;
          _loading = false;
        });
        _suppressMiAuthLifecycle();
        _startMiAuthVerification();
      }
    } catch (e) {
      logger.error('LoginForm: MiAuth Direct error', e);
      if (mounted) {
        setState(() => _loading = false);
        _showError(e.toString());
      }
    }
  }

  void _cancelMiAuth() {
    _stopMiAuthPolling();
    _cancelMiAuthTimeout();
    _unregisterDeepLinkCallback();
    _restoreMiAuthLifecycle();
    setState(() => _currentStep = LoginStep.misskeyDirectLogin);
  }

  // ── MiAuth Token 登录 ──────────────────────────────────────────

  Future<void> _loginWithToken() async {
    final host = _tokenHostController.text.trim();
    final token = _tokenController.text.trim();
    if (host.isEmpty || token.isEmpty) {
      showToast(
        title: '请填写实例地址和访问令牌',
        type: ToastificationType.warning,
      );
      return;
    }

    logger.info('LoginForm: Starting Misskey Token login for $host');
    setState(() => _loading = true);
    try {
      final success = await ref
          .read(authServiceProvider.notifier)
          .loginWithToken(host, token);

      if (!mounted) return;

      if (success) {
        widget.onLoginSuccess?.call();
        if (widget.isBottomSheet) Navigator.pop(context);
      }
    } catch (e) {
      logger.error('LoginForm: MiAuth Token login error', e);
      if (mounted) {
        showToast(
          title: '登录失败：$e',
          type: ToastificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String error) {
    _stopMiAuthPolling();
    _cancelMiAuthTimeout();
    _unregisterDeepLinkCallback();
    _restoreMiAuthLifecycle();
    showToast(
      title: 'auth_error'.tr(namedArgs: {'error': error}),
      type: ToastificationType.error,
    );
    widget.onLoginFailed?.call();
  }

  // ── UI 构建 ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final padding = MediaQuery.paddingOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + viewInsets.bottom + padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginFormHeader(
            currentStep: _currentStep,
            onBack: _loading ? null : _back,
          ),
          const SizedBox(height: 16),
          Flexible(child: _buildCurrentStep()),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case LoginStep.loginMethod:
        if (widget.showPlatformSelection) {
          return LoginMethodSelection(
            onMiAuthDirect: () => _setStep(LoginStep.misskeyDirectLogin),
            onMiAuthToken: () => _setStep(LoginStep.tokenInstructions),
          );
        } else {
          return const SizedBox.shrink();
        }
      case LoginStep.misskeyDirectLogin:
        return HostInputStep(
          hostController: _misskeyHostController,
          loading: _loading,
          onLogin: _startMisskeyAuth,
        );
      case LoginStep.tokenInstructions:
        return TokenInstructionsStep(
          onUnderstood: () => _setStep(LoginStep.tokenInput),
          onBack: () {
            _connectivityWarning = null;
            _setStep(LoginStep.loginMethod);
          },
          connectivityWarning: _connectivityWarning,
        );
      case LoginStep.tokenInput:
        return TokenInputStep(
          hostController: _tokenHostController,
          tokenController: _tokenController,
          loading: _loading,
          onLogin: _loginWithToken,
        );
      case LoginStep.misskeyCheckAuth:
        return MisskeyCheckAuthStep(
          onCancel: _cancelMiAuth,
          onManualCheck: _manualCheckMiAuth,
          proxyWarning: _proxyWarning,
        );
    }
  }
}
