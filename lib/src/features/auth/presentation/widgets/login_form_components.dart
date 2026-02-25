import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

/// 登录表单步骤枚举
enum LoginStep {
  select,
  misskeyLogin,
  flarumLogin,
  flarumEndpoint,
  misskeyCheckAuth,
}

/// 登录表单数据模型
class LoginFormData {
  String? misskeyHost;
  String? misskeySession;
  String flarumHost;
  String flarumUsername;
  String flarumPassword;
  String flarumEndpoint;
  bool isQuickLogin;

  LoginFormData({
    this.misskeyHost,
    this.misskeySession,
    this.flarumHost = '',
    this.flarumUsername = '',
    this.flarumPassword = '',
    this.flarumEndpoint = '',
    this.isQuickLogin = false,
  });

  LoginFormData copyWith({
    String? misskeyHost,
    String? misskeySession,
    String? flarumHost,
    String? flarumUsername,
    String? flarumPassword,
    String? flarumEndpoint,
    bool? isQuickLogin,
  }) {
    return LoginFormData(
      misskeyHost: misskeyHost ?? this.misskeyHost,
      misskeySession: misskeySession ?? this.misskeySession,
      flarumHost: flarumHost ?? this.flarumHost,
      flarumUsername: flarumUsername ?? this.flarumUsername,
      flarumPassword: flarumPassword ?? this.flarumPassword,
      flarumEndpoint: flarumEndpoint ?? this.flarumEndpoint,
      isQuickLogin: isQuickLogin ?? this.isQuickLogin,
    );
  }
}

/// 登录表单控制器
class LoginFormController extends ChangeNotifier {
  LoginStep _currentStep = LoginStep.select;
  LoginFormData _formData = LoginFormData();
  bool _loading = false;

  LoginStep get currentStep => _currentStep;
  LoginFormData get formData => _formData;
  bool get loading => _loading;

  void setStep(LoginStep step) {
    _currentStep = step;
    notifyListeners();
  }

  void updateFormData(LoginFormData data) {
    _formData = data;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void back() {
    switch (_currentStep) {
      case LoginStep.misskeyCheckAuth:
        _currentStep = LoginStep.misskeyLogin;
        break;
      case LoginStep.select:
        break;
      default:
        _currentStep = LoginStep.select;
        _formData = LoginFormData();
        break;
    }
    notifyListeners();
  }

  void reset() {
    _currentStep = LoginStep.select;
    _formData = LoginFormData();
    _loading = false;
    notifyListeners();
  }
}

/// 平台选择卡片
class PlatformSelectionCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isVertical;

  const PlatformSelectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.isVertical,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isVertical
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: icon,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: icon,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// 平台选择步骤
class PlatformSelectionStep extends StatelessWidget {
  final VoidCallback onMisskeySelected;
  final VoidCallback onFlarumLoginSelected;
  final VoidCallback onFlarumEndpointSelected;

  const PlatformSelectionStep({
    super.key,
    required this.onMisskeySelected,
    required this.onFlarumLoginSelected,
    required this.onFlarumEndpointSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('select'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  const Color(0xFF66CCFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'auth_choose_platform'.tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 8),

          PlatformSelectionCard(
            icon: Image.asset(
              'assets/icons/misskey.png',
              width: 32,
              height: 32,
            ),
            title: 'Misskey',
            subtitle: 'auth_add_account_misskey_subtitle'.tr(),
            color: Theme.of(context).colorScheme.primary,
            onTap: onMisskeySelected,
            isVertical: false,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: PlatformSelectionCard(
                  icon: Image.asset(
                    'assets/icons/flarum.png',
                    width: 32,
                    height: 32,
                  ),
                  title: 'Flarum',
                  subtitle: 'Login',
                  color: Colors.deepOrange,
                  onTap: onFlarumLoginSelected,
                  isVertical: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PlatformSelectionCard(
                  icon: const Icon(Icons.api, color: Colors.blue, size: 32),
                  title: 'Flarum',
                  subtitle: 'Endpoint',
                  color: Colors.blue,
                  onTap: onFlarumEndpointSelected,
                  isVertical: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Misskey登录步骤
class MisskeyLoginStep extends ConsumerWidget {
  final TextEditingController hostController;
  final bool loading;
  final VoidCallback onLogin;

  const MisskeyLoginStep({
    super.key,
    required this.hostController,
    required this.loading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      key: const ValueKey('misskey'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'auth_misskey_host_hint'.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: hostController,
            decoration: InputDecoration(
              labelText: 'auth_misskey_host'.tr(),
              hintText: 'misskey.io',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.language),
              prefixText: 'https://',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: loading ? null : onLogin,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: loading
                ? const SizedBox.shrink()
                : const Icon(Icons.arrow_forward),
            label: loading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Text('auth_next'.tr()),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Misskey检查授权步骤
class MisskeyCheckAuthStep extends StatelessWidget {
  final bool loading;
  final VoidCallback onCheck;

  const MisskeyCheckAuthStep({
    super.key,
    required this.loading,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const ValueKey('misskey_check'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  'auth_authorization_instructions'.tr(),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: loading ? null : onCheck,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: loading
                ? const SizedBox.shrink()
                : const Icon(Icons.check_circle_outline),
            label: loading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text('auth_done'.tr()),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Flarum登录步骤
class FlarumLoginStep extends StatelessWidget {
  final TextEditingController hostController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool loading;
  final bool isQuickLogin;
  final VoidCallback onLogin;
  final VoidCallback onQuickLogin;

  const FlarumLoginStep({
    super.key,
    required this.hostController,
    required this.usernameController,
    required this.passwordController,
    required this.loading,
    required this.isQuickLogin,
    required this.onLogin,
    required this.onQuickLogin,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('flarum'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: hostController,
            decoration: InputDecoration(
              labelText: 'auth_flarum_host'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.language_outlined),
              hintText: 'discuss.flarum.org',
              suffixIcon: isQuickLogin
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        hostController.clear();
                      },
                    )
                  : null,
            ),
            readOnly: isQuickLogin,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: 'auth_username_email'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.person_outline),
              hintText: '用户名或邮箱',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'auth_password'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: loading ? null : onLogin,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: loading ? const SizedBox.shrink() : const Icon(Icons.login),
            label: loading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Text('auth_login'.tr()),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: loading ? null : onQuickLogin,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: Colors.deepOrange.withValues(alpha: 0.5)),
              foregroundColor: Colors.deepOrange,
            ),
            icon: Image.asset('assets/icons/flarum.png', width: 20, height: 20),
            label: const Text('快速填充 iMikufans 域名'),
          ),
        ],
      ),
    );
  }
}

/// Flarum端点步骤
class FlarumEndpointStep extends StatelessWidget {
  final TextEditingController endpointController;
  final bool loading;
  final VoidCallback onAdd;

  const FlarumEndpointStep({
    super.key,
    required this.endpointController,
    required this.loading,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('endpoint'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: endpointController,
            decoration: InputDecoration(
              labelText: 'auth_flarum_server_url'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.link),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: loading ? null : onAdd,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_link),
            label: Text('auth_add_endpoint'.tr()),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 登录表单头部
class LoginFormHeader extends StatelessWidget {
  final LoginStep currentStep;
  final VoidCallback? onBack;

  const LoginFormHeader({
    super.key,
    required this.currentStep,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    switch (currentStep) {
      case LoginStep.select:
        return const SizedBox.shrink();
      case LoginStep.misskeyLogin:
        title = 'auth_add_account_misskey_title'.tr();
        break;
      case LoginStep.misskeyCheckAuth:
        title = 'auth_waiting_authorization'.tr();
        break;
      case LoginStep.flarumLogin:
        title = 'auth_add_account_flarum_title'.tr();
        break;
      case LoginStep.flarumEndpoint:
        title = 'auth_add_account_flarum_endpoint_title'.tr();
        break;
    }

    return Row(
      children: [
        if (currentStep != LoginStep.select)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
