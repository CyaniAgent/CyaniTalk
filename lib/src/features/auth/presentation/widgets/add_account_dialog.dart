import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/logger.dart';
import '../../application/auth_service.dart';
import '../../../../core/api/flarum_api.dart';

/// 统一的添加账户或端点对话框
class AddAccountDialog extends ConsumerStatefulWidget {
  const AddAccountDialog({super.key});

  @override
  ConsumerState<AddAccountDialog> createState() => _AddAccountDialogState();
}

enum _AddAccountStep { select, misskeyLogin, flarumLogin, flarumEndpoint }

class _AddAccountDialogState extends ConsumerState<AddAccountDialog> {
  _AddAccountStep _step = _AddAccountStep.select;

  // Controllers
  final _misskeyHostController = TextEditingController();
  final _flarumHostController = TextEditingController();
  final _flarumUsernameController = TextEditingController();
  final _flarumPasswordController = TextEditingController();
  final _flarumEndpointController = TextEditingController();

  bool _loading = false;

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
      _step = _AddAccountStep.select;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    switch (_step) {
      case _AddAccountStep.select:
        title = 'auth_add_account_select_title'.tr();
        break;
      case _AddAccountStep.misskeyLogin:
        title = 'auth_add_account_misskey_title'.tr();
        break;
      case _AddAccountStep.flarumLogin:
        title = 'auth_add_account_flarum_title'.tr();
        break;
      case _AddAccountStep.flarumEndpoint:
        title = 'auth_add_account_flarum_endpoint_title'.tr();
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
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: _step == _AddAccountStep.select
                ? TextAlign.center
                : TextAlign.start,
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
      case _AddAccountStep.flarumLogin:
        return _buildFlarumLoginStep();
      case _AddAccountStep.flarumEndpoint:
        return _buildFlarumEndpointStep();
    }
  }

  Widget _buildSelectStep() {
    return Column(
      key: const ValueKey('select'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOptionCard(
          icon: Image.asset('assets/icons/misskey.png', width: 24, height: 24),
          title: 'auth_add_account_misskey_option'.tr(),
          subtitle: 'auth_add_account_misskey_subtitle'.tr(),
          color: Colors.green,
          onTap: () => setState(() => _step = _AddAccountStep.misskeyLogin),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          icon: Image.asset('assets/icons/flarum.png', width: 24, height: 24),
          title: 'auth_add_account_flarum_option'.tr(),
          subtitle: 'auth_add_account_flarum_subtitle'.tr(),
          color: Colors.deepOrange,
          onTap: () => setState(() => _step = _AddAccountStep.flarumLogin),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          icon: Icon(Icons.api, color: Colors.blue),
          title: 'auth_add_account_flarum_endpoint_option'.tr(),
          subtitle: 'auth_add_account_flarum_endpoint_subtitle'.tr(),
          color: Colors.blue,
          onTap: () => setState(() => _step = _AddAccountStep.flarumEndpoint),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMisskeyLoginStep() {
    return Column(
      key: const ValueKey('misskey'),
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _misskeyHostController,
          decoration: InputDecoration(
            labelText: 'auth_misskey_host'.tr(),
            border: const OutlineInputBorder(),
            prefixText: 'https://',
          ),
          autofocus: true,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _loading ? null : _startMisskeyAuth,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('auth_next'.tr()),
        ),
      ],
    );
  }

  Widget _buildFlarumLoginStep() {
    return Column(
      key: const ValueKey('flarum'),
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _flarumHostController,
          decoration: InputDecoration(
            labelText: 'auth_flarum_host'.tr(),
            border: const OutlineInputBorder(),
            prefixText: 'https://',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _flarumUsernameController,
          decoration: InputDecoration(
            labelText: 'auth_username_email'.tr(),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _flarumPasswordController,
          decoration: InputDecoration(
            labelText: 'auth_password'.tr(),
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _loading ? null : _loginToFlarum,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('auth_login'.tr()),
        ),
      ],
    );
  }

  Widget _buildFlarumEndpointStep() {
    return Column(
      key: const ValueKey('endpoint'),
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _flarumEndpointController,
          decoration: InputDecoration(
            labelText: 'auth_flarum_server_url'.tr(),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _loading ? null : _addFlarumEndpoint,
          child: Text('auth_add_endpoint'.tr()),
        ),
      ],
    );
  }

  Future<void> _startMisskeyAuth() async {
    final host = _misskeyHostController.text.trim();
    if (host.isEmpty) return;

    // Preliminary check for protocol
    String displayHost = host;
    if (host.contains('://')) {
      displayHost = host.split('://').last;
    }
    if (displayHost.contains('/')) {
      displayHost = displayHost.split('/').first;
    }

    logger.info(
      'AddAccountDialog: Starting Misskey authentication for host: $displayHost',
    );
    setState(() => _loading = true);
    try {
      final session = await ref
          .read(authServiceProvider.notifier)
          .startMiAuth(host);
      if (mounted) {
        logger.info(
          'AddAccountDialog: Successfully started MiAuth for host: $host',
        );
        Navigator.pop(context);
        _showCheckAuthDialog(context, ref, host, session);
      }
    } catch (e) {
      logger.error(
        'AddAccountDialog: Error starting Misskey authentication for host: $host',
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

  Future<void> _loginToFlarum() async {
    final host = _flarumHostController.text.trim();
    final user = _flarumUsernameController.text.trim();
    final password = _flarumPasswordController.text;

    if (host.isEmpty || user.isEmpty || password.isEmpty) return;

    logger.info(
      'AddAccountDialog: Starting Flarum login for host: $host, user: $user',
    );
    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider.notifier)
          .loginToFlarum(host, user, password);
      if (mounted) {
        logger.info(
          'AddAccountDialog: Successfully logged in to Flarum for host: $host',
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('auth_flarum_linked'.tr())));
        Navigator.pop(context);
      }
    } catch (e) {
      logger.error(
        'AddAccountDialog: Error logging in to Flarum for host: $host',
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

    logger.info('AddAccountDialog: Adding Flarum endpoint: $url');
    setState(() => _loading = true);
    try {
      await FlarumApi().saveEndpoint(url);
      if (mounted) {
        logger.info(
          'AddAccountDialog: Successfully added Flarum endpoint: $url',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auth_flarum_endpoint_added'.tr())),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      logger.error('AddAccountDialog: Error adding Flarum endpoint: $url', e);
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

  void _showCheckAuthDialog(
    BuildContext context,
    WidgetRef ref,
    String host,
    String session,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CheckAuthDialog(host: host, session: session),
    );
  }
}

class _CheckAuthDialog extends ConsumerStatefulWidget {
  final String host;
  final String session;

  const _CheckAuthDialog({required this.host, required this.session});

  @override
  ConsumerState<_CheckAuthDialog> createState() => _CheckAuthDialogState();
}

class _CheckAuthDialogState extends ConsumerState<_CheckAuthDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('auth_waiting_authorization'.tr()),
      content: Text('auth_authorization_instructions'.tr()),
      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : () {
                  logger.info(
                    'CheckAuthDialog: Cancelling authentication process',
                  );
                  Navigator.pop(context);
                },
          child: Text('auth_cancel'.tr()),
        ),
        FilledButton(
          onPressed: _loading
              ? null
              : () async {
                  logger.info(
                    'CheckAuthDialog: Checking MiAuth status for host: ${widget.host}',
                  );
                  setState(() => _loading = true);
                  final isMounted = mounted;
                  final dialogContext = context;
                  try {
                    await ref
                        .read(authServiceProvider.notifier)
                        .checkMiAuth(widget.host, widget.session);
                    if (isMounted) {
                      logger.info(
                        'CheckAuthDialog: MiAuth successful for host: ${widget.host}',
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(dialogContext);
                    }
                  } catch (e) {
                    logger.error(
                      'CheckAuthDialog: MiAuth failed for host: ${widget.host}',
                      e,
                    );
                    setState(() => _loading = false);
                    if (isMounted) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            'auth_failed'.tr(
                              namedArgs: {
                                'error':
                                    'Please make sure you have approved the application in your browser before clicking Done.',
                              },
                            ),
                          ),
                          duration: const Duration(seconds: 8),
                          action: SnackBarAction(
                            label: 'auth_retry'.tr(),
                            onPressed: () {}, // User can just click Done again
                          ),
                        ),
                      );
                    }
                  }
                },
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('auth_done'.tr()),
        ),
      ],
    );
  }
}
