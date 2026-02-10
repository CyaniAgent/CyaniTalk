import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/logger.dart';
import '../../data/misskey_repository.dart';
import '../../application/aiscript_interpreter.dart';

class MisskeyAiScriptConsolePage extends ConsumerStatefulWidget {
  const MisskeyAiScriptConsolePage({super.key});

  @override
  ConsumerState<MisskeyAiScriptConsolePage> createState() =>
      _MisskeyAiScriptConsolePageState();
}

class _MisskeyAiScriptConsolePageState
    extends ConsumerState<MisskeyAiScriptConsolePage> {
  final TextEditingController _codeController = TextEditingController();
  final List<String> _output = [];
  bool _isRunning = false;

  final List<String> _availableScripts = [
    'lib/aiscripts/hello.aiscript',
    'lib/aiscripts/miku.aiscript',
  ];

  Future<void> _loadScript(String path) async {
    try {
      final code = await rootBundle.loadString(path);
      setState(() {
        _codeController.text = code;
        _output.add('Loaded script: $path');
      });
    } catch (e) {
      logger.error('Failed to load script: $path', e);
      setState(() {
        _output.add('Error loading script: $e');
      });
    }
  }

  Future<void> _runScript() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isRunning = true;
      _output.clear(); // Clear previous output for a fresh run
    });

    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final interpreter = AiScriptInterpreter(repository);

      await interpreter.execute(code);

      if (mounted) {
        setState(() {
          _output.addAll(interpreter.output);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _output.add('[FATAL] $e');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  void _clearConsole() {
    setState(() {
      _output.clear();
    });
  }

  void _showExampleScripts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'aiscript_console_scripts'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ..._availableScripts.map((path) {
                final name = path.split('/').last;
                return ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(name),
                  onTap: () {
                    _loadScript(path);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'clear_console',
                    onPressed: _clearConsole,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: const Icon(Icons.delete_outline),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onLongPress: () => _showExampleScripts(context),
                    child: FloatingActionButton.extended(
                      heroTag: 'run_aiscript',
                      onPressed: _isRunning ? null : _runScript,
                      icon: _isRunning
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text('aiscript_console_run'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: _buildCodeInput(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildConsoleOutput(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: _buildCodeInput(),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 1,
          child: _buildConsoleOutput(),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.code, size: 18),
            const SizedBox(width: 8),
            Text(
              'Editor',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TextField(
            controller: _codeController,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'aiscript_console_hint'.tr(),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsoleOutput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.terminal, size: 18),
            const SizedBox(width: 8),
            Text(
              'Output',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: ListView.builder(
              itemCount: _output.length,
              itemBuilder: (context, index) {
                return Text(
                  _output[index],
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    height: 1.4,
                  ),
                ).animate().fadeIn(duration: 200.ms);
              },
            ),
          ),
        ),
      ],
    );
  }
}