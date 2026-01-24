import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _flarumTokenController = TextEditingController();
  final _flarumEndpointController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _misskeyHostController.dispose();
    _flarumHostController.dispose();
    _flarumUsernameController.dispose();
    _flarumTokenController.dispose();
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
        title = 'Add Account or Endpoint';
        break;
      case _AddAccountStep.misskeyLogin:
        title = 'Log in with Misskey';
        break;
      case _AddAccountStep.flarumLogin:
        title = 'Log in with Flarum';
        break;
      case _AddAccountStep.flarumEndpoint:
        title = 'Configure Flarum Endpoint';
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
            textAlign: _step == _AddAccountStep.select ? TextAlign.center : TextAlign.start,
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
          icon: Icons.public,
          title: 'Log in with Misskey',
          subtitle: 'Connect using MiAuth',
          color: Colors.green,
          onTap: () => setState(() => _step = _AddAccountStep.misskeyLogin),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          icon: Icons.forum,
          title: 'Log in with Flarum',
          subtitle: 'Connect using API Token',
          color: Colors.deepOrange,
          onTap: () => setState(() => _step = _AddAccountStep.flarumLogin),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          icon: Icons.api,
          title: 'Configure Flarum Endpoint',
          subtitle: 'Add a custom forum server',
          color: Colors.blue,
          onTap: () => setState(() => _step = _AddAccountStep.flarumEndpoint),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
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
          decoration: const InputDecoration(
            labelText: 'Host (e.g. misskey.io)',
            border: OutlineInputBorder(),
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
              : const Text('Next'),
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
          decoration: const InputDecoration(
            labelText: 'Host (e.g. discuss.flarum.org)',
            border: OutlineInputBorder(),
            prefixText: 'https://',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _flarumUsernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _flarumTokenController,
          decoration: const InputDecoration(
            labelText: 'Token',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _loading ? null : _linkFlarumAccount,
          child: const Text('Add Account'),
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
          decoration: const InputDecoration(
            labelText: 'Server URL (e.g. https://flarum.org)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _loading ? null : _addFlarumEndpoint,
          child: const Text('Add Endpoint'),
        ),
      ],
    );
  }

  Future<void> _startMisskeyAuth() async {
    final host = _misskeyHostController.text.trim();
    if (host.isEmpty) return;

    setState(() => _loading = true);
    try {
      final session = await ref.read(authServiceProvider.notifier).startMiAuth(host);
      if (mounted) {
        Navigator.pop(context);
        _showCheckAuthDialog(context, ref, host, session);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _linkFlarumAccount() async {
    final host = _flarumHostController.text.trim();
    final user = _flarumUsernameController.text.trim();
    final token = _flarumTokenController.text.trim();

    if (host.isEmpty || user.isEmpty || token.isEmpty) return;

    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider.notifier).linkFlarumAccount(host, token, user);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
          const SnackBar(content: Text('Flarum endpoint added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
      builder: (context) => AlertDialog(
        title: const Text('Waiting for Authorization'),
        content: const Text(
          'Please authorize the app in your browser, then click "Done".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(authServiceProvider.notifier)
                    .checkMiAuth(host, session);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Misskey account linked successfully!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
