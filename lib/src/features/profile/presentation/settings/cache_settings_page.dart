import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cyanitalk/src/core/utils/cache_manager.dart';
import 'package:cyanitalk/src/core/services/app_reset_service.dart';
import 'package:cyanitalk/src/core/services/misskey_image_cache_database.dart';
import 'package:cyanitalk/src/features/auth/application/auth_service.dart';

/// 缓存设置页面组件
class CacheSettingsPage extends ConsumerStatefulWidget {
  const CacheSettingsPage({super.key});

  @override
  ConsumerState<CacheSettingsPage> createState() => _CacheSettingsPageState();
}

class _CacheSettingsPageState extends ConsumerState<CacheSettingsPage> {
  String? _cachePath;
  int _totalCacheSize = 0;
  int _sqliteCacheSize = 0;
  int? _cacheTimeLimit;

  bool _isBasicSettingsLoading = true;
  bool _isStatsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCacheSettings();
  }

  Future<void> _loadCacheSettings() async {
    final selectedMisskeyAccount = await ref.read(
      selectedMisskeyAccountProvider.future,
    );
    final currentAccountId = selectedMisskeyAccount?.id;
    cacheManager.setCurrentAccountId(currentAccountId);

    try {
      final cacheDir = await cacheManager.getCacheDirectory();
      final cacheTimeLimit = await cacheManager.getCacheTimeLimit();

      if (mounted) {
        setState(() {
          _cachePath = cacheDir.path;
          _cacheTimeLimit = cacheTimeLimit;
          _isBasicSettingsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isBasicSettingsLoading = false);
      debugPrint('Error loading basic cache settings: $e');
    }

    try {
      final totalSize = await cacheManager.getTotalCacheSize();
      final sqliteSize = await MisskeyImageCacheDatabase().getTotalCacheSize();

      if (mounted) {
        setState(() {
          _totalCacheSize = totalSize;
          _sqliteCacheSize = sqliteSize;
          _isStatsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isStatsLoading = false);
      debugPrint('Error loading storage stats: $e');
    }
  }

  Future<void> _selectCustomCacheDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择缓存目录',
      );

      if (selectedDirectory != null && mounted) {
        await cacheManager.setCustomCacheDirectory(selectedDirectory);
        await _loadCacheSettings();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('缓存目录已更新'), behavior: SnackBarBehavior.floating));
        }
      }
    } catch (e) {
      debugPrint('Error selecting cache directory: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择缓存目录失败: $e'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _resetApp() async {
    bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认重置应用'),
            content: Text(
              '这将清除所有账户、设置 and 缓存数据，使应用恢复到首次打开的状态。此操作无法撤销，应用将自动退出。'.tr(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('确认重置', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm && mounted) {
      try {
        await ref.read(appResetProvider.notifier).resetApp();

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('重置成功'),
              content: const Text('应用数据已清空。为了完成重置，应用需要关闭。请手动重新启动应用。'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('好的'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('重置失败: $e'), behavior: SnackBarBehavior.floating));
        }
      }
    }
  }

  Future<void> _clearContentCache() async {
    bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认清除内容缓存'),
            content: const Text('确定要清除所有内容缓存文件吗？SQLite 缓存数据不受影响。此操作无法撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('确定'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await cacheManager.clearAllCache();
        setState(() => _isStatsLoading = true);
        await _loadCacheSettings();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('内容缓存已清除'), behavior: SnackBarBehavior.floating));
        }
      } catch (e) {
        debugPrint('Error clearing content cache: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('清除内容缓存失败: $e'), behavior: SnackBarBehavior.floating));
        }
      }
    }
  }

  Future<void> _clearAllCache() async {
    bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('你确定要清理全部缓存？'),
            content: const Text(
              '这将会清理所有的缓存文件，并清理在本地数据库存放的所有缓存数据。确定继续清理？',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('确定清理', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await cacheManager.clearAllCache();
        await MisskeyImageCacheDatabase().clearAllSqliteCache();
        setState(() => _isStatsLoading = true);
        await _loadCacheSettings();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('全部缓存已清除'), behavior: SnackBarBehavior.floating));
        }
      } catch (e) {
        debugPrint('Error clearing all cache: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('清除全部缓存失败: $e'), behavior: SnackBarBehavior.floating));
        }
      }
    }
  }

  Future<void> _setCacheTimeLimit() async {
    final List<int?> options = [null, 1, 3, 7, 14, 30, 60, 90, 180, 365];
    int? selectedValue = _cacheTimeLimit;

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) {
          return AlertDialog(
            title: const Text('设置缓存时间上限'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((days) {
                final label = days == null ? '不限时长' : '$days 天';
                // ignore: deprecated_member_use
                return RadioListTile<int?>(
                  title: Text(label),
                  value: days,
                  // ignore: deprecated_member_use
                  groupValue: selectedValue,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    dialogSetState(() {
                      selectedValue = value;
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('确定'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true) {
      try {
        await cacheManager.setCacheTimeLimit(selectedValue);
        await _loadCacheSettings();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('缓存时间上限已更新'), behavior: SnackBarBehavior.floating));
        }
      } catch (e) {
        debugPrint('Error setting cache time limit: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('设置缓存时间上限失败: $e'), behavior: SnackBarBehavior.floating));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('存储设置')),
      body: _isBasicSettingsLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 12),

                // 缓存路径设置
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '缓存路径',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _cachePath ?? '未知',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            onPressed: _selectCustomCacheDirectory,
                            child: const Text('更改'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(indent: 16, endIndent: 16, height: 32),

                // 缓存概览
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '缓存概览',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('内容缓存'),
                          Text(
                            _isStatsLoading
                                ? 'common_calculating'.tr()
                                : _formatBytes(_totalCacheSize),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('SQLite 缓存'),
                          Text(
                            _isStatsLoading
                                ? 'common_calculating'.tr()
                                : _formatBytes(_sqliteCacheSize),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(indent: 16, endIndent: 16, height: 32),

                // 缓存时间上限
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '缓存时间上限',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('当前设置'),
                          Text(
                            _cacheTimeLimit == null
                                ? '不限时长'
                                : '$_cacheTimeLimit 天',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _setCacheTimeLimit,
                          icon: const Icon(Icons.access_time_outlined),
                          label: const Text('调整缓存时间上限'),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(indent: 16, endIndent: 16, height: 32),

                // 缓存管理（清理按钮）
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '缓存管理',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _clearContentCache,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('清理内容缓存'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: _clearAllCache,
                              icon: const Icon(
                                Icons.cleaning_services_outlined,
                              ),
                              label: const Text('清理全部缓存'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(indent: 16, endIndent: 16, height: 32),

                // 危险区域
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '危险区域',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _resetApp,
                          icon: const Icon(Icons.refresh),
                          label: const Text('重置此应用'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'storage_reset_app_warning'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red.withAlpha(204),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
