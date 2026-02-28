import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_form_components.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/core/api/flarum_api.dart';
import '/src/core/utils/logger.dart';

/// 统一的登录表单控件
///
/// 这个控件包含了所有的登录步骤，可以作为一个独立的控件使用，
/// 也可以作为页面的一部分使用。
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
  LoginStep _currentStep = LoginStep.select;
  bool _loading = false;
  bool _isQuickLogin = false;

  final _misskeyHostController = TextEditingController();
  final _flarumHostController = TextEditingController();
  final _flarumUsernameController = TextEditingController();
  final _flarumPasswordController = TextEditingController();
  final _flarumEndpointController = TextEditingController();

  String? _misskeyHost;
  String? _misskeySession;

  @override
  void initState() {
    super.initState();
    if (widget.initialHost != null) {
      _misskeyHostController.text = widget.initialHost!;
    }
  }

  @override
  void dispose() {
    _misskeyHostController.dispose();
    _flarumHostController.dispose();
    _flarumUsernameController.dispose();
    _flarumPasswordController.dispose();
    _flarumEndpointController.dispose();
    super.dispose();
  }

  void _setStep(LoginStep step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _back() {
    switch (_currentStep) {
      case LoginStep.misskeyCheckAuth:
        _setStep(LoginStep.misskeyLogin);
        break;
      case LoginStep.select:
        break;
      default:
        _setStep(LoginStep.select);
        _isQuickLogin = false;
        _flarumHostController.clear();
        break;
    }
  }

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

    logger.info('LoginForm: Starting Misskey auth for $displayHost');
    setState(() => _loading = true);
    try {
      final session = await ref
          .read(authServiceProvider.notifier)
          .startMiAuth(host);
      if (mounted) {
        setState(() {
          _misskeyHost = host;
          _misskeySession = session;
          _currentStep = LoginStep.misskeyCheckAuth;
          _loading = false;
        });
      }
    } catch (e) {
      logger.error('LoginForm: MiAuth error', e);
      if (mounted) {
        setState(() => _loading = false);
        _showError(e.toString());
      }
    }
  }

  Future<void> _checkMisskeyAuth() async {
    if (_misskeyHost == null || _misskeySession == null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider.notifier)
          .checkMiAuth(_misskeyHost!, _misskeySession!);
      if (mounted) {
        setState(() => _loading = false);
        widget.onLoginSuccess?.call();
        if (widget.isBottomSheet) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      logger.error('LoginForm: MiAuth check failed', e);
      if (mounted) {
        setState(() => _loading = false);
        _showError(
          'auth_failed'.tr(
            namedArgs: {'error': 'Please ensure you approved the app.'},
          ),
        );
      }
    }
  }

  Future<void> _loginToFlarum() async {
    final host = _flarumHostController.text.trim();
    final user = _flarumUsernameController.text.trim();
    final password = _flarumPasswordController.text;

    if (host.isEmpty || user.isEmpty || password.isEmpty) return;

    logger.info(
      'LoginForm: Starting Flarum login for host: $host, user: $user',
    );
    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider.notifier)
          .loginToFlarum(host, user, password);
      if (mounted) {
        setState(() => _loading = false);
        widget.onLoginSuccess?.call();
        if (widget.isBottomSheet) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      logger.error('LoginForm: Flarum login failed', e);
      if (mounted) {
        setState(() => _loading = false);
        _showError(e.toString());
      }
    }
  }

  Future<void> _addFlarumEndpoint() async {
    final endpoint = _flarumEndpointController.text.trim();
    if (endpoint.isEmpty) return;

    logger.info('LoginForm: Adding Flarum endpoint: $endpoint');
    setState(() => _loading = true);
    try {
      await FlarumApi().saveEndpoint(endpoint);
      if (mounted) {
        setState(() => _loading = false);
        widget.onLoginSuccess?.call();
        if (widget.isBottomSheet) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      logger.error('LoginForm: Add Flarum endpoint failed', e);
      if (mounted) {
        setState(() => _loading = false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('auth_error'.tr(namedArgs: {'error': error})),
        behavior: SnackBarBehavior.floating,
      ),
    );
    widget.onLoginFailed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + padding.bottom),
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
      case LoginStep.select:
        if (widget.showPlatformSelection) {
          return PlatformSelectionStep(
            onMisskeySelected: () => _setStep(LoginStep.misskeyLogin),
            onFlarumLoginSelected: () {
              _flarumHostController.clear();
              _isQuickLogin = false;
              _setStep(LoginStep.flarumLogin);
            },
            onFlarumEndpointSelected: () => _setStep(LoginStep.flarumEndpoint),
          );
        } else {
          return const SizedBox.shrink();
        }
      case LoginStep.misskeyLogin:
        return MisskeyLoginStep(
          hostController: _misskeyHostController,
          loading: _loading,
          onLogin: _startMisskeyAuth,
        );
      case LoginStep.misskeyCheckAuth:
        return MisskeyCheckAuthStep(
          loading: _loading,
          onCheck: _checkMisskeyAuth,
        );
      case LoginStep.flarumLogin:
        return FlarumLoginStep(
          hostController: _flarumHostController,
          usernameController: _flarumUsernameController,
          passwordController: _flarumPasswordController,
          loading: _loading,
          isQuickLogin: _isQuickLogin,
          onLogin: _loginToFlarum,
          onQuickLogin: () {
            setState(() {
              _flarumHostController.text = 'flarum.imikufans.cn';
              _isQuickLogin = true;
            });
          },
        );
      case LoginStep.flarumEndpoint:
        return FlarumEndpointStep(
          endpointController: _flarumEndpointController,
          loading: _loading,
          onAdd: _addFlarumEndpoint,
        );
    }
  }
}
