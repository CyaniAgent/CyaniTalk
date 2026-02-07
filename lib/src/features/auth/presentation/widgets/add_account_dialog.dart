import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/logger.dart';
import '../../application/auth_service.dart';
import '../../../../core/api/flarum_api.dart';
import '../../../../core/api/juhe_auth_api.dart';
import '../juhe_auth_page.dart';

/// 统一的添加账户或端点底部表单
class AddAccountBottomSheet {
  /// 显示添加账户底部表单
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _AddAccountBottomSheetContent(),
    );
  }
}

/// 添加账户底部表单内容
class _AddAccountBottomSheetContent extends ConsumerStatefulWidget {
  const _AddAccountBottomSheetContent();

  @override
  ConsumerState<_AddAccountBottomSheetContent> createState() =>
      _AddAccountBottomSheetContentState();
}

enum _AddAccountStep {
  select,
  misskeyLogin,
  flarumLogin,
  flarumEndpoint,
  flarumSocialLogin,
  misskeyCheckAuth,
}

class _AddAccountBottomSheetContentState
    extends ConsumerState<_AddAccountBottomSheetContent> {
  _AddAccountStep _step = _AddAccountStep.select;

  // State for Misskey Auth
  String? _misskeyHost;
  String? _misskeySession;

  // Controllers
  final _misskeyHostController = TextEditingController();
  final _flarumHostController = TextEditingController();
  final _flarumUsernameController = TextEditingController();
  final _flarumPasswordController = TextEditingController();
  final _flarumEndpointController = TextEditingController();

  bool _loading = false;
  bool _isQuickLogin = false; // 标记是否为快速登录模式

  @override
  void dispose() {
    _misskeyHostController.dispose();
    _flarumHostController.dispose();
    _flarumUsernameController.dispose();
    _flarumPasswordController.dispose();
    _flarumEndpointController.dispose();
    super.dispose();
  }

  void _back() {
    setState(() {
      if (_step == _AddAccountStep.misskeyCheckAuth) {
        _step = _AddAccountStep.misskeyLogin;
      } else {
        _step = _AddAccountStep.select;
        _isQuickLogin = false; // 返回选择页面时重置快速登录标志
      }
    });
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
          _buildHeader(),
          const SizedBox(height: 16),
          Flexible(child: _buildCurrentStep()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    switch (_step) {
      case _AddAccountStep.select:
        return const SizedBox.shrink();
      case _AddAccountStep.misskeyLogin:
        title = 'auth_add_account_misskey_title'.tr();
        break;
      case _AddAccountStep.misskeyCheckAuth:
        title = 'auth_waiting_authorization'.tr();
        break;
      case _AddAccountStep.flarumLogin:
        title = 'auth_add_account_flarum_title'.tr();
        break;
      case _AddAccountStep.flarumEndpoint:
        title = 'auth_add_account_flarum_endpoint_title'.tr();
        break;
      case _AddAccountStep.flarumSocialLogin:
        title = 'auth_login_wechat'.tr();
        break;
    }

    return Row(
      children: [
        if (_step != _AddAccountStep.select)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _loading ? null : _back,
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

  Widget _buildCurrentStep() {
    switch (_step) {
      case _AddAccountStep.select:
        return _buildSelectStep();
      case _AddAccountStep.misskeyLogin:
        return _buildMisskeyLoginStep();
      case _AddAccountStep.misskeyCheckAuth:
        return _buildMisskeyCheckAuthStep();
      case _AddAccountStep.flarumLogin:
        return _buildFlarumLoginStep();
      case _AddAccountStep.flarumEndpoint:
        return _buildFlarumEndpointStep();
      case _AddAccountStep.flarumSocialLogin:
        return _buildFlarumSocialLoginStep();
    }
  }

  Widget _buildSelectStep() {
    return SingleChildScrollView(
      key: const ValueKey('select'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF39C5BB), Color(0xFF66CCFF)],
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

          // Misskey Button (Full Width)
          _buildStyledCard(
            icon: Image.asset(
              'assets/icons/misskey.png',
              width: 32,
              height: 32,
            ),
            title: 'Misskey',
            subtitle: 'auth_add_account_misskey_subtitle'.tr(),
            color: const Color(0xFF39C5BB),
            onTap: () => setState(() => _step = _AddAccountStep.misskeyLogin),
            isVertical: false,
          ),
          const SizedBox(height: 16),

                    // Flarum Row

                    Row(

                      children: [

                        Expanded(

                          child: _buildStyledCard(

                            icon: Image.asset(

                              'assets/icons/flarum.png',

                              width: 32,

                              height: 32,

                            ),

                            title: 'Flarum',

                            subtitle: 'Login',

                            color: Colors.deepOrange,

                            onTap: () {

                              _flarumHostController.clear();

                              _isQuickLogin = false;

                              setState(() => _step = _AddAccountStep.flarumLogin);

                            },

                            isVertical: true,

                          ),

                        ),

                        const SizedBox(width: 16),

                        Expanded(

                          child: _buildStyledCard(

                            icon: const Icon(Icons.api, color: Colors.blue, size: 32),

                            title: 'Flarum',

                            subtitle: 'Endpoint',

                            color: Colors.blue,

                            onTap: () =>

                                setState(() => _step = _AddAccountStep.flarumEndpoint),

                            isVertical: true,

                          ),

                        ),

                      ],

                    ),

                  ],

                ),

           // .animate().fadeIn().slideY(...) removed to simplify for now, can add back if needed
    );
  }

  Widget _buildFlarumSocialLoginStep() {
    return SingleChildScrollView(
      key: const ValueKey('flarum_social'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'auth_flarum_host_hint'.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _flarumHostController,
            decoration: InputDecoration(
              labelText: 'auth_flarum_host'.tr(),
              hintText: 'flarum.imikufans.cn',
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
            onPressed: _loading ? null : () => _checkAndStartWeChatLogin(),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.arrow_forward),
            label: _loading
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
          OutlinedButton.icon(
            onPressed: _loading ? null : () {
              // 重置为非快速登录模式，以便返回Flarum登录界面时显示正确的选项
              setState(() {
                _isQuickLogin = false;
                _step = _AddAccountStep.flarumLogin;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.arrow_back),
            label: Text('auth_cancel'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAndStartWeChatLogin() async {
    final host = _flarumHostController.text.trim();
    if (host.isEmpty) return;

    // Normalize host
    String fullUrl = host;
    if (!host.startsWith('http')) {
      fullUrl = 'https://$host';
    }

    setState(() => _loading = true);
    try {
      // 创建FlarumApi实例并设置基础URL
      final flarumApi = FlarumApi();
      flarumApi.setBaseUrl(fullUrl);
      
      // 获取Clogin OAuth配置
      final cloginConfig = await flarumApi.getCloginConfig();
      
      if (cloginConfig == null ||
          cloginConfig['app_id'] == null ||
          cloginConfig['app_key'] == null) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth_wechat_config_not_found'.tr()),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // 使用动态配置创建JuheAuthApi
      final juheApi = JuheAuthApi(
        appid: cloginConfig['app_id']!,
        appkey: cloginConfig['app_key']!,
        apiurl: cloginConfig['api_url'] ?? 'https://u.cccyun.cc/',
      );

      if (mounted) {
        setState(() => _loading = false);

        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => JuheAuthPage(type: 'wx', api: juheApi),
          ),
        );

        if (result != null && result.containsKey('social_uid')) {
          _loginWithSocial(fullUrl, result, 'wx');
        } else if (result != null && result.containsKey('error')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login error: ${result['error']}')),
            );
          }
        }
      }
    } catch (e) {
      logger.error('AddAccountBottomSheet: Error getting Clogin config', e);
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth_wechat_config_error'.tr()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loginWithSocial(
    String host,
    Map<String, dynamic> socialData,
    String type,
  ) async {
    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider.notifier)
          .loginToFlarumWithSocial(
            host,
            socialData['social_uid'],
            type,
            nickname: socialData['nickname'],
            avatarUrl: socialData['faceimg'],
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('auth_flarum_linked'.tr())));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Social login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildStyledCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isVertical,
  }) {
    final theme = Theme.of(context);
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildMisskeyLoginStep() {
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
            controller: _misskeyHostController,
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
            onPressed: _loading ? null : _startMisskeyAuth,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.arrow_forward),
            label: _loading
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

  Widget _buildMisskeyCheckAuthStep() {
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
            onPressed: _loading ? null : _checkMisskeyAuth,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.check_circle_outline),
            label: _loading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Text('auth_done'.tr()),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ); // .animate()... removed for simplicity
  }

  Widget _buildFlarumLoginStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const ValueKey('flarum'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _flarumHostController,
            decoration: InputDecoration(
              labelText: 'auth_flarum_host'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.language_outlined),
              hintText: 'discuss.flarum.org',
              suffixIcon: _isQuickLogin
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _isQuickLogin = false;
                          _flarumHostController.clear();
                        });
                      },
                    )
                  : null,
            ),
            readOnly: _isQuickLogin,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _flarumUsernameController,
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
            controller: _flarumPasswordController,
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
            onPressed: _loading ? null : _loginToFlarum,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _loading ? const SizedBox.shrink() : const Icon(Icons.login),
            label: _loading
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
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'auth_or'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          
          // WeChat Login Button
          OutlinedButton.icon(
            onPressed: _loading ? null : () => setState(() => _step = _AddAccountStep.flarumSocialLogin),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: const Color(0xFF07C160).withValues(alpha: 0.5)),
              foregroundColor: const Color(0xFF07C160),
            ),
            icon: const Icon(Icons.wechat),
            label: Text('auth_login_wechat'.tr()),
          ),
          const SizedBox(height: 12),
          
          // Quick Login to iMikufans Button
          OutlinedButton.icon(
            onPressed: _loading ? null : () {
              setState(() {
                _flarumHostController.text = 'flarum.imikufans.cn';
                _isQuickLogin = true;
              });
            },
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

  Widget _buildFlarumEndpointStep() {
    return SingleChildScrollView(
      key: const ValueKey('endpoint'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _flarumEndpointController,
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
            onPressed: _loading ? null : _addFlarumEndpoint,
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

    logger.info(
      'AddAccountBottomSheet: Starting Misskey auth for $displayHost',
    );
    setState(() => _loading = true);
    try {
      final session = await ref
          .read(authServiceProvider.notifier)
          .startMiAuth(host);
      if (mounted) {
        setState(() {
          _misskeyHost = host;
          _misskeySession = session;
          _step = _AddAccountStep.misskeyCheckAuth;
          _loading = false;
        });
      }
    } catch (e) {
      logger.error('AddAccountBottomSheet: MiAuth error', e);
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth_error'.tr(namedArgs: {'error': e.toString()})),
          ),
        );
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
        Navigator.pop(context);
      }
    } catch (e) {
      logger.error('AddAccountBottomSheet: MiAuth check failed', e);
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'auth_failed'.tr(
                namedArgs: {'error': 'Please ensure you approved the app.'},
              ),
            ),
            duration: const Duration(seconds: 4),
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
      'AddAccountBottomSheet: Starting Flarum login for host: $host, user: $user',
    );
    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider.notifier)
          .loginToFlarum(host, user, password);
      if (mounted) {
        logger.info(
          'AddAccountBottomSheet: Successfully logged in to Flarum for host: $host',
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('auth_flarum_linked'.tr())));
        Navigator.pop(context);
      }
    } catch (e) {
      logger.error(
        'AddAccountBottomSheet: Error logging in to Flarum for host: $host',
        e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth_error'.tr(namedArgs: {'error': e.toString()})),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addFlarumEndpoint() async {
    final url = _flarumEndpointController.text.trim();
    if (url.isEmpty) return;

    setState(() => _loading = true);
    try {
      await FlarumApi().saveEndpoint(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auth_flarum_endpoint_added'.tr())),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      logger.error('AddAccountBottomSheet: Flarum endpoint error', e);
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth_error'.tr(namedArgs: {'error': e.toString()})),
          ),
        );
      }
    }
  }
}
