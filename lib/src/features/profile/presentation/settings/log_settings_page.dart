import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/profile/application/log_settings_provider.dart';
import '/src/core/utils/logger.dart';

class LogSettingsPage extends ConsumerStatefulWidget {
  const LogSettingsPage({super.key});

  @override
  ConsumerState<LogSettingsPage> createState() => _LogSettingsPageState();
}

class _LogSettingsPageState extends ConsumerState<LogSettingsPage> {
  List<File> _logFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshFileList();
  }

  Future<void> _refreshFileList() async {
    setState(() => _isLoading = true);
    final files = await logger.listLogFiles();
    if (mounted) {
      setState(() {
        _logFiles = files;
        _isLoading = false;
      });
    }
  }

  Future<void> _exportLogs() async {
    final file = await logger.exportLogs();
    if (mounted) {
      if (file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'settings_logs_export_success'.tr(namedArgs: {'path': file.path}),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('settings_logs_export_failed'.tr()), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _deleteAllLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_logs_delete_all'.tr()),
        content: Text('settings_logs_delete_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('accounts_remove_cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('accounts_remove_confirm_button'.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await logger.deleteLogs();
      await _refreshFileList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('settings_logs_delete_success'.tr()), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(logSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings_logs_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFileList,
          ),
        ],
      ),
      body: settings.when(
        data: (config) => ListView(
          children: [
            _buildSectionHeader(context, 'settings_logs_section_basic'.tr()),
            _buildLevelTile(context, config),
            _buildMaxSizeTile(context, config),
            SwitchListTile(
              title: Text('settings_logs_auto_clear'.tr()),
              subtitle: Text('settings_logs_auto_clear_desc'.tr()),
              value: config.autoClear,
              onChanged: (value) =>
                  ref.read(logSettingsProvider.notifier).setAutoClear(value),
            ),
            if (config.autoClear) _buildRetentionTile(context, config),

            const Divider(),
            _buildSectionHeader(context, 'settings_logs_section_history'.tr()),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text('settings_logs_view'.tr()),
              onTap: () => _viewCurrentLogs(context),
            ),
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: Text('settings_logs_export'.tr()),
              onTap: _exportLogs,
            ),
            ListTile(
              leading: Icon(
                Icons.delete_sweep_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'settings_logs_delete_all'.tr(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: _deleteAllLogs,
            ),

            const Divider(),
            _buildSectionHeader(context, 'settings_logs_file_list'.tr()),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_logFiles.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('settings_logs_empty'.tr()),
                ),
              )
            else
              ..._logFiles.map((file) => _buildFileTile(context, file)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLevelTile(BuildContext context, LogSettings config) {
    return ListTile(
      title: Text('settings_logs_level'.tr()),
      subtitle: Text('settings_logs_level_desc'.tr()),
      trailing: DropdownButton<String>(
        value: config.logLevel.toLowerCase(),
        items: ['debug', 'info', 'warning', 'error']
            .map(
              (l) => DropdownMenuItem(value: l, child: Text(l.toUpperCase())),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            ref.read(logSettingsProvider.notifier).setLogLevel(value);
          }
        },
      ),
    );
  }

  Widget _buildMaxSizeTile(BuildContext context, LogSettings config) {
    return ListTile(
      title: Text('settings_logs_max_size'.tr()),
      subtitle: Text('settings_logs_max_size_desc'.tr()),
      trailing: SizedBox(
        width: 80,
        child: TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.end,
          decoration: const InputDecoration(suffixText: ' MB'),
          controller: TextEditingController(text: config.maxLogSize.toString()),
          onSubmitted: (value) {
            final size = int.tryParse(value);
            if (size != null && size > 0) {
              ref.read(logSettingsProvider.notifier).setMaxLogSize(size);
            }
          },
        ),
      ),
    );
  }

  Widget _buildRetentionTile(BuildContext context, LogSettings config) {
    return ListTile(
      title: Text('settings_logs_retention_days'.tr()),
      subtitle: Text('settings_logs_retention_days_desc'.tr()),
      trailing: SizedBox(
        width: 80,
        child: TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.end,
          decoration: const InputDecoration(suffixText: ' Days'),
          controller: TextEditingController(
            text: config.retentionDays.toString(),
          ),
          onSubmitted: (value) {
            final days = int.tryParse(value);
            if (days != null && days > 0) {
              ref.read(logSettingsProvider.notifier).setRetentionDays(days);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFileTile(BuildContext context, File file) {
    final fileNameWithSuffix = file.path
        .split(Platform.isWindows ? r'\' : '/')
        .last;
    final fileName = fileNameWithSuffix
        .replaceAll('.log', '')
        .replaceAll('.txt', '');

    final stat = file.statSync();
    final size = (stat.size / 1024).toStringAsFixed(1);
    final isCurrent = file.path == logger.logFilePath;

    // 根据文件名生成确定的“随机”字母 (A-Z)
    final charCode = 65 + (fileName.hashCode.abs() % 26);
    final letter = String.fromCharCode(charCode);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCurrent
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(
          letter,
          style: TextStyle(
            color: isCurrent
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        fileName,
        style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : null),
      ),
      subtitle: Text('${stat.modified.toString().split('.').first} • $size KB'),
      onTap: () => _viewFileContent(context, file),
    );
  }

  void _viewCurrentLogs(BuildContext context) {
    final path = logger.logFilePath;
    if (path != null) {
      _viewFileContent(context, File(path));
    }
  }

  Future<void> _viewFileContent(BuildContext context, File file) async {
    if (!file.existsSync()) return;

    final content = await file.readAsLines();
    if (!context.mounted) return;

    final fileNameWithSuffix = file.path
        .split(Platform.isWindows ? r'\' : '/')
        .last;
    final fileName = fileNameWithSuffix
        .replaceAll('.log', '')
        .replaceAll('.txt', '');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(fileName),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy_all),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: content.join('\n')),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard'), behavior: SnackBarBehavior.floating),
                    );
                  }
                },
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: content.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: _buildColoredLogLine(context, content[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColoredLogLine(BuildContext context, String line) {
    Color color = Theme.of(context).colorScheme.onSurface;
    FontWeight weight = FontWeight.normal;

    final upperLine = line.toUpperCase();

    if (upperLine.contains('[E]') || upperLine.contains('ERROR')) {
      color = Colors.redAccent;
      weight = FontWeight.bold;
    } else if (upperLine.contains('[W]') ||
        upperLine.contains('WARN') ||
        upperLine.contains('WARNING')) {
      color = Colors.orangeAccent;
      weight = FontWeight.bold;
    } else if (upperLine.contains('[I]') || upperLine.contains('INFO')) {
      color = Colors.blueAccent;
    } else if (upperLine.contains('[D]') || upperLine.contains('DEBUG')) {
      color = Colors.grey;
    }

    return SelectableText(
      line,
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 11,
        color: color,
        fontWeight: weight,
      ),
    );
  }
}
