import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/profile/application/log_settings_provider.dart';
import '/src/core/utils/logger.dart';
import '/src/core/widgets/settings_widgets.dart';

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

  static const _brown = Color(0xFF8D6E63);
  static const _cyan = Color(0xFF26A69A);
  static const _amber = Color(0xFFFFCA28);

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
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            SettingsCardGroup(
              children: [
                _buildLevelTile(config),
                _buildMaxSizeTile(config),
                _buildAutoClearTile(config),
                if (config.autoClear) _buildRetentionTile(config),
              ],
            ),

            const SizedBox(height: 16),
            SettingsCardGroup(
              children: [
                SettingsTile(
                  icon: Icons.description_outlined,
                  iconColor: _brown,
                  title: 'settings_logs_view'.tr(),
                  onTap: () => _viewCurrentLogs(context),
                ),
                SettingsTile(
                  icon: Icons.file_upload_outlined,
                  iconColor: _brown,
                  title: 'settings_logs_export'.tr(),
                  onTap: _exportLogs,
                ),
                SettingsTile(
                  icon: Icons.delete_sweep_outlined,
                  iconColor: Colors.red,
                  title: 'settings_logs_delete_all'.tr(),
                  onTap: _deleteAllLogs,
                ),
              ],
            ),

            const SizedBox(height: 16),
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
        error: (_, _) => Center(child: Text('Error')),
      ),
    );
  }

  Widget _buildLevelTile(LogSettings config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _brown.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune, color: _brown, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settings_logs_level'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text('settings_logs_level_desc'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: config.logLevel.toLowerCase(),
            items: ['debug', 'info', 'warning', 'error']
                .map((l) => DropdownMenuItem(value: l, child: Text(l.toUpperCase())))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(logSettingsProvider.notifier).setLogLevel(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaxSizeTile(LogSettings config) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _cyan.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storage, color: _cyan, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settings_logs_max_size'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text('settings_logs_max_size_desc'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(suffixText: ' MB', isDense: true),
              controller: TextEditingController(text: config.maxLogSize.toString()),
              onSubmitted: (value) {
                final size = int.tryParse(value);
                if (size != null && size > 0) {
                  ref.read(logSettingsProvider.notifier).setMaxLogSize(size);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoClearTile(LogSettings config) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _amber.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_delete, color: _amber, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settings_logs_auto_clear'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text('settings_logs_auto_clear_desc'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: config.autoClear,
            onChanged: (value) => ref.read(logSettingsProvider.notifier).setAutoClear(value),
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionTile(LogSettings config) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _amber.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today, color: _amber, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settings_logs_retention_days'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text('settings_logs_retention_days_desc'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(suffixText: ' Days', isDense: true),
              controller: TextEditingController(text: config.retentionDays.toString()),
              onSubmitted: (value) {
                final days = int.tryParse(value);
                if (days != null && days > 0) {
                  ref.read(logSettingsProvider.notifier).setRetentionDays(days);
                }
              },
            ),
          ),
        ],
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
