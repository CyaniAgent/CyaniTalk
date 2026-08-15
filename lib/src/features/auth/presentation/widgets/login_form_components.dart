import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

part 'login_form_components.g.dart';

/// 登录表单步骤枚举
enum LoginStep {
  /// 选择登录方式（MiAuth Direct / MiAuth Token）
  loginMethod,
  /// MiAuth Direct：输入实例 URL
  misskeyDirectLogin,
  /// MiAuth Token：操作步骤指引
  tokenInstructions,
  /// MiAuth Token：输入实例 URL + 访问令牌
  tokenInput,
  /// MiAuth 验证中（轮询/Deep Link）
  misskeyCheckAuth,
}

/// 登录表单数据模型
class LoginFormData {
  final String? misskeyHost;
  final String? misskeySession;

  const LoginFormData({this.misskeyHost, this.misskeySession});

  LoginFormData copyWith({String? misskeyHost, String? misskeySession}) {
    return LoginFormData(
      misskeyHost: misskeyHost ?? this.misskeyHost,
      misskeySession: misskeySession ?? this.misskeySession,
    );
  }
}

/// 登录表单控制器 (当前未接入 login_form.dart)
@riverpod
class LoginFormController extends _$LoginFormController {
  @override
  LoginFormData build() => const LoginFormData();

  void updateFormData(LoginFormData data) {
    state = data;
  }

  void reset() {
    state = const LoginFormData();
  }
}

// ── 登录方式选择 ──────────────────────────────────────────────────

/// 登录方式选择页面：MiAuth Direct vs MiAuth Token
class LoginMethodSelection extends StatelessWidget {
  final VoidCallback onMiAuthDirect;
  final VoidCallback onMiAuthToken;

  const LoginMethodSelection({
    super.key,
    required this.onMiAuthDirect,
    required this.onMiAuthToken,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const ValueKey('login_method'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MethodCard(
            icon: Icons.login_rounded,
            title: 'auth_method_direct_title'.tr(),
            subtitle: 'auth_method_direct_subtitle'.tr(),
            color: theme.colorScheme.primary,
            onTap: onMiAuthDirect,
          ),
          const SizedBox(height: 16),
          _MethodCard(
            icon: Icons.vpn_key_rounded,
            title: 'auth_method_token_title'.tr(),
            subtitle: 'auth_method_token_subtitle'.tr(),
            color: theme.colorScheme.tertiary,
            onTap: onMiAuthToken,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 登录方式卡片
class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── MiAuth Direct：实例 URL 输入 ──────────────────────────────────

/// Misskey 实例 URL 输入步骤（用于 MiAuth Direct）
class HostInputStep extends StatelessWidget {
  final TextEditingController hostController;
  final bool loading;
  final VoidCallback onLogin;

  const HostInputStep({
    super.key,
    required this.hostController,
    required this.loading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('host_input'),
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
            scrollPadding: const EdgeInsets.only(bottom: 120),
            onSubmitted: loading ? null : (_) => onLogin(),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: loading ? null : onLogin,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
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

// ── MiAuth Token：操作步骤指引 ────────────────────────────────────

/// MiAuth Token 操作步骤指引页面
class TokenInstructionsStep extends StatelessWidget {
  final VoidCallback onUnderstood;
  final VoidCallback onBack;

  const TokenInstructionsStep({
    super.key,
    required this.onUnderstood,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const ValueKey('token_instructions'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'auth_token_instructions_intro'.tr(),
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _InstructionStep(
                  number: '1',
                  title: 'auth_token_step1_title'.tr(),
                  description: 'auth_token_step1_desc'.tr(),
                  theme: theme,
                ),
                const _StepDivider(),
                _InstructionStep(
                  number: '2',
                  title: 'auth_token_step2_title'.tr(),
                  description: 'auth_token_step2_desc'.tr(),
                  theme: theme,
                ),
                const _StepDivider(),
                _InstructionStep(
                  number: '3',
                  title: 'auth_token_step3_title'.tr(),
                  description: 'auth_token_step3_desc'.tr(),
                  theme: theme,
                ),
                const _StepDivider(),
                _InstructionStep(
                  number: '4',
                  title: 'auth_token_step4_title'.tr(),
                  description: 'auth_token_step4_desc'.tr(),
                  theme: theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onUnderstood,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: Text('auth_token_i_understand'.tr()),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text('back'.tr()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 操作步骤条目
class _InstructionStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final ThemeData theme;

  const _InstructionStep({
    required this.number,
    required this.title,
    required this.description,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 步骤之间的分隔线
class _StepDivider extends StatelessWidget {
  const _StepDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 1,
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── MiAuth Token：实例 URL + 访问令牌输入 ─────────────────────────

/// MiAuth Token 输入页面
class TokenInputStep extends StatefulWidget {
  final TextEditingController hostController;
  final TextEditingController tokenController;
  final bool loading;
  final VoidCallback onLogin;

  const TokenInputStep({
    super.key,
    required this.hostController,
    required this.tokenController,
    required this.loading,
    required this.onLogin,
  });

  @override
  State<TokenInputStep> createState() => _TokenInputStepState();
}

class _TokenInputStepState extends State<TokenInputStep> {
  bool _obscureToken = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const ValueKey('token_input'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'auth_misskey_host_hint'.tr(),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.hostController,
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
            scrollPadding: const EdgeInsets.only(bottom: 200),
          ),
          const SizedBox(height: 24),
          Text(
            'auth_token_input_hint'.tr(),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.tokenController,
            obscureText: _obscureToken,
            decoration: InputDecoration(
              labelText: 'auth_token_input_label'.tr(),
              hintText: 'xxxxxxxxxxxxxxxx',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.vpn_key),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureToken ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscureToken = !_obscureToken);
                },
              ),
            ),
            scrollPadding: const EdgeInsets.only(bottom: 200),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: widget.loading ? null : widget.onLogin,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            icon: widget.loading
                ? const SizedBox.shrink()
                : const Icon(Icons.login),
            label: widget.loading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text('auth_token_login'.tr()),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── MiAuth 验证中 ─────────────────────────────────────────────────

/// Misskey 检查授权步骤
class MisskeyCheckAuthStep extends StatefulWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onManualCheck;
  final String? proxyWarning;

  const MisskeyCheckAuthStep({
    super.key,
    this.onCancel,
    this.onManualCheck,
    this.proxyWarning,
  });

  @override
  State<MisskeyCheckAuthStep> createState() => _MisskeyCheckAuthStepState();
}

class _MisskeyCheckAuthStepState extends State<MisskeyCheckAuthStep>
    with SingleTickerProviderStateMixin {
  bool _showCancel = false;
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showCancel = true);
    });
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    )..forward();
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

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
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _timerAnimation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _timerAnimation.value,
                            strokeWidth: 3,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                          );
                        },
                      ),
                      const CyaniLoadingIndicator(size: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'auth_authorization_instructions'.tr(),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _CheckStepIndicator(
                        number: '1',
                        text: 'auth_check_step1'.tr(),
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _CheckStepIndicator(
                        number: '2',
                        text: 'auth_check_step2'.tr(),
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _CheckStepIndicator(
                        number: '3',
                        text: 'auth_check_step3'.tr(),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                if (widget.proxyWarning != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.proxyWarning!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.onManualCheck,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text('auth_check_auth_status'.tr()),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'auth_auto_polling_hint'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (_showCancel && widget.onCancel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close, size: 18),
              label: Text('cancel'.tr()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 验证页面步骤指示器
class _CheckStepIndicator extends StatelessWidget {
  final String number;
  final String text;
  final ThemeData theme;

  const _CheckStepIndicator({
    required this.number,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ── 表单头部 ──────────────────────────────────────────────────────

/// 登录表单头部
class LoginFormHeader extends StatelessWidget {
  final LoginStep currentStep;
  final VoidCallback? onBack;

  const LoginFormHeader({super.key, required this.currentStep, this.onBack});

  @override
  Widget build(BuildContext context) {
    String title;
    switch (currentStep) {
      case LoginStep.loginMethod:
        return const SizedBox.shrink();
      case LoginStep.misskeyDirectLogin:
        title = 'auth_method_direct_title'.tr();
        break;
      case LoginStep.tokenInstructions:
      case LoginStep.tokenInput:
        title = 'auth_method_token_title'.tr();
        break;
      case LoginStep.misskeyCheckAuth:
        title = 'auth_waiting_authorization'.tr();
        break;
    }

    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (onBack != null) const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
