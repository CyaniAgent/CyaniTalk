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
  ConsumerState<MisskeyAiScriptConsolePage> createState() => _MisskeyAiScriptConsolePageState();
}

class _MisskeyAiScriptConsolePageState extends ConsumerState<MisskeyAiScriptConsolePage> {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'aiscript_console_scripts'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableScripts.map((path) {
                      final name = path.split('/').last;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(name),
                          onPressed: () => _loadScript(path),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _codeController,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Enter AiScript code here...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isRunning ? null : _runScript,
                  icon: _isRunning 
                    ? SizedBox(
                        width: 18, 
                        height: 18, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary)
                      )
                    : const Icon(Icons.play_arrow),
                  label: const Text('Run Script'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _clearConsole,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Output'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _output.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _output[index],
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ).animate().fadeIn(duration: 200.ms);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}