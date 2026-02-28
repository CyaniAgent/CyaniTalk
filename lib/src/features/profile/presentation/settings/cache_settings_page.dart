import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cyanitalk/src/core/utils/cache_manager.dart';
import 'package:cyanitalk/src/core/services/app_reset_service.dart';
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
  Map<CacheCategory, int> _categoryCacheSizes = {};
  Map<CacheCategory, int?> _categoryMaxSizes = {};
  int _maxCacheSize = CacheManager.defaultMaxCacheSize;
  AudioCacheType _audioCacheType = AudioCacheType.temporary;

  // 分离加载状态
  bool _isBasicSettingsLoading = true;
  bool _isStatsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCacheSettings();
  }

  /// 加载缓存设置与真实的系统统计
  Future<void> _loadCacheSettings() async {
    // 获取当前选中的账户ID
    final selectedMisskeyAccount = await ref.read(
      selectedMisskeyAccountProvider.future,
    );
    final selectedFlarumAccount = await ref.read(
      selectedFlarumAccountProvider.future,
    );
    final currentAccountId =
        selectedMisskeyAccount?.id ?? selectedFlarumAccount?.id;

    // 设置当前账户ID到缓存管理器
    cacheManager.setCurrentAccountId(currentAccountId);

    // 首先加载基础配置（较快）
    try {
      final cacheDir = await cacheManager.getCacheDirectory();
      final maxSize = await cacheManager.getMaxCacheSize();
      final audioCacheType = await cacheManager.getAudioCacheType();

      if (mounted) {
        setState(() {
          _cachePath = cacheDir.path;
          _maxCacheSize = maxSize;
          _audioCacheType = audioCacheType;
          _isBasicSettingsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isBasicSettingsLoading = false);
      debugPrint('Error loading basic cache settings: $e');
    }

    // 然后并行加载统计数据（可能较慢，涉及磁盘扫描）
    try {
      final totalSize = await cacheManager.getTotalCacheSize();

      // 加载各分类缓存大小
      final categorySizes = <CacheCategory, int>{};
      final categoryMaxSizes = <CacheCategory, int?>{};
      for (final category in CacheCategory.values) {
        final size = await cacheManager.getCategoryCacheSize(category);
        final maxSize = await cacheManager.getCategoryMaxSize(category);
        categorySizes[category] = size;
        categoryMaxSizes[category] = maxSize;
      }

      if (mounted) {
        setState(() {
          _totalCacheSize = totalSize;
          _categoryCacheSizes = categorySizes;
          _categoryMaxSizes = categoryMaxSizes;
          _isStatsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isStatsLoading = false);
      debugPrint('Error loading storage stats: $e');
    }
  }

  /// 选择自定义缓存目录
  Future<void> _selectCustomCacheDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择缓存目录',
      );

      if (selectedDirectory != null && mounted) {
        await cacheManager.setCustomCacheDirectory(selectedDirectory);

        // 重新加载基础设置
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

  /// 重置应用程序
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

  /// 清除所有缓存
  Future<void> _clearAllCache() async {
    bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认清除缓存'),
            content: const Text('确定要清除所有缓存文件吗？此操作无法撤销。'),
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
        // 重新触发统计加载
        setState(() => _isStatsLoading = true);
        await _loadCacheSettings();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('缓存已清除'), behavior: SnackBarBehavior.floating));
        }
      } catch (e) {
        debugPrint('Error clearing cache: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('清除缓存失败: $e'), behavior: SnackBarBehavior.floating));
        }
      }
    }
  }

  /// 清除指定类别的缓存
  Future<void> _clearCategoryCache(CacheCategory category) async {
    bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认清除缓存'),
            content: Text('确定要清除${_getCategoryName(category)}缓存吗？此操作无法撤销。'),
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
        await cacheManager.clearCategoryCache(category);
        setState(() => _isStatsLoading = true);
        await _loadCacheSettings();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_getCategoryName(category)}缓存已清除'), behavior: SnackBarBehavior.floating),
          );
        }
      } catch (e) {
        debugPrint('Error clearing category cache: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('清除${_getCategoryName(category)}缓存失败: $e'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  /// 设置最大缓存大小
  Future<void> _setMaximumCacheSize() async {
    final TextEditingController controller = TextEditingController(
      text: (_maxCacheSize / (1024 * 1024)).toStringAsFixed(0),
    );

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置最大缓存大小'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '最大缓存大小 (MB)',
                hintText: '例如: 100',
              ),
            ),
            const SizedBox(height: 16),
            Text('当前设置: ${_formatBytes(_maxCacheSize)}'),
          ],
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
      ),
    );

    if (confirmed == true) {
      try {
        final sizeInMB = double.tryParse(controller.text);
        if (sizeInMB != null && sizeInMB > 0) {
          final sizeInBytes = (sizeInMB * 1024 * 1024).toInt();
          await cacheManager.setMaxCacheSize(sizeInBytes);
          await _loadCacheSettings();

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('最大缓存大小已更新'), behavior: SnackBarBehavior.floating));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('请输入有效的缓存大小'), behavior: SnackBarBehavior.floating));
          }
        }
      } catch (e) {
        debugPrint('Error setting max cache size: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('设置最大缓存大小失败: $e'), behavior: SnackBarBehavior.floating));
        }
      }
    }
  }

  /// 设置分类最大缓存大小
  Future<void> _setCategoryMaxSize(CacheCategory category) async {
    final currentSize = _categoryMaxSizes[category];
    final TextEditingController controller = TextEditingController(
      text: currentSize != null
          ? (currentSize / (1024 * 1024)).toStringAsFixed(0)
          : '',
    );

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('设置${_getCategoryName(category)}最大缓存大小'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '最大缓存大小 (MB)',
                hintText: '例如: 50, 留空使用全局设置',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '当前设置: ${currentSize != null ? _formatBytes(currentSize) : '使用全局设置'}',
            ),
          ],
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
      ),
    );

    if (confirmed == true) {
      try {
        if (controller.text.isEmpty) {
          // 留空逻辑
        } else {
          final sizeInMB = double.tryParse(controller.text);
          if (sizeInMB != null && sizeInMB > 0) {
            final sizeInBytes = (sizeInMB * 1024 * 1024).toInt();
            await cacheManager.setCategoryMaxSize(category, sizeInBytes);
            await _loadCacheSettings();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_getCategoryName(category)}最大缓存大小已更新'),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('请输入有效的缓存大小'), behavior: SnackBarBehavior.floating));
            }
          }
        }
      } catch (e) {
        debugPrint('Error setting category max cache size: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('设置${_getCategoryName(category)}最大缓存大小失败: $e'),
            ),
          );
        }
      }
    }
  }

  /// 设置音频缓存类型
  Future<void> _setAudioCacheType() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('设置音频缓存类型'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ignore: deprecated_member_use
                RadioListTile<AudioCacheType>(
                  title: const Text('持久化'),
                  subtitle: const Text('音频文件会一直保留，不会自动清理'),
                  value: AudioCacheType.persistent,
                  selected: _audioCacheType == AudioCacheType.persistent,
                  // ignore: deprecated_member_use
                  groupValue: _audioCacheType,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _audioCacheType = value;
                      });
                    }
                  },
                ),
                // ignore: deprecated_member_use
                RadioListTile<AudioCacheType>(
                  title: const Text('非持久化'),
                  subtitle: const Text('音频文件会根据缓存大小限制自动清理'),
                  value: AudioCacheType.temporary,
                  selected: _audioCacheType == AudioCacheType.temporary,
                  // ignore: deprecated_member_use
                  groupValue: _audioCacheType,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _audioCacheType = value;
                      });
                    }
                  },
                ),
              ],
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
        await cacheManager.setAudioCacheType(_audioCacheType);
        await _loadCacheSettings();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('音频缓存类型已更新')));
        }
      } catch (e) {
        debugPrint('Error setting audio cache type: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('设置音频缓存类型失败: $e')));
        }
      }
    }
  }

  /// 查看缓存文件列表
  Future<void> _viewCacheFiles() async {
    try {
      final items = await cacheManager.getAllCacheItems();

      if (mounted) {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => CacheFilesListPage(cacheItems: items),
              ),
            )
            .then((_) {
              _loadCacheSettings();
            });
      }
    } catch (e) {
      debugPrint('Error loading cache files: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载缓存文件失败: $e')));
      }
    }
  }

  /// 获取分类名称
  String _getCategoryName(CacheCategory category) {
    switch (category) {
      case CacheCategory.audio:
        return '音频';
      case CacheCategory.image:
        return '图片';
      case CacheCategory.timeline:
        return '时间线';
      case CacheCategory.other:
        return '其他';
    }
  }

  /// 构建设置行
  Widget _buildSettingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    );
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

                // 缓存控制
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '缓存控制',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingRow(
                        '本应用缓存数据',
                        _isStatsLoading
                            ? 'common_calculating'.tr()
                            : _formatBytes(_totalCacheSize),
                      ),
                      _buildSettingRow('单类别最大上限', _formatBytes(_maxCacheSize)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _setMaximumCacheSize,
                          icon: const Icon(Icons.speed_outlined),
                          label: const Text('调整最大缓存限额'),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(indent: 16, endIndent: 16, height: 32),

                // 音频缓存设置
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '音频缓存设置',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingRow(
                        '当前缓存策略',
                        _audioCacheType == AudioCacheType.persistent
                            ? '持久化'
                            : '非持久化',
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: _setAudioCacheType,
                          child: const Text('管理音频缓存策略'),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(indent: 16, endIndent: 16, height: 32),

                // 缓存分类管理
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '内容分类管理',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ..._categoryCacheSizes.entries.map((entry) {
                        final category = entry.key;
                        final size = entry.value;
                        final maxSize = _categoryMaxSizes[category];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(_getCategoryIcon(category)),
                                title: Text(_getCategoryName(category)),
                                subtitle: Text(
                                  '${_isStatsLoading ? 'common_calculating'.tr() : _formatBytes(size)} / ${maxSize != null ? _formatBytes(maxSize) : "无限制"}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _clearCategoryCache(category),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _setCategoryMaxSize(category),
                                      icon: const Icon(Icons.settings_outlined),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _viewCacheFiles,
                              icon: const Icon(Icons.list_alt_outlined),
                              label: const Text('详细文件列表'),
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

  IconData _getCategoryIcon(CacheCategory category) {
    switch (category) {
      case CacheCategory.audio:
        return Icons.audiotrack_outlined;
      case CacheCategory.image:
        return Icons.image_outlined;
      case CacheCategory.timeline:
        return Icons.timeline_outlined;
      case CacheCategory.other:
        return Icons.more_horiz_outlined;
    }
  }

  /// 将字节数转换为可读格式
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

/// 缓存文件列表页面
class CacheFilesListPage extends StatefulWidget {
  final List<CacheItem> cacheItems;

  const CacheFilesListPage({super.key, required this.cacheItems});

  @override
  State<CacheFilesListPage> createState() => _CacheFilesListPageState();
}

class _CacheFilesListPageState extends State<CacheFilesListPage> {
  final List<CacheItem> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('缓存文件列表'),
        actions: [
          if (_selectedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedItems,
              tooltip: '删除选中文件',
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.cacheItems.length,
        itemBuilder: (context, index) {
          final item = widget.cacheItems[index];
          final isSelected = _selectedItems.contains(item);

          return ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: item.canBeCleared
                  ? (value) {
                      setState(() {
                        if (value == true) {
                          _selectedItems.add(item);
                        } else {
                          _selectedItems.remove(item);
                        }
                      });
                    }
                  : null,
            ),
            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('大小: ${_formatBytes(item.size)}'),
                Text('修改时间: ${item.modified.toString().substring(0, 19)}'),
                Text('分类: ${_getCategoryName(item.category)}'),
                if (!item.canBeCleared)
                  const Text('不可清除', style: TextStyle(color: Colors.red)),
              ],
            ),
            onTap: item.canBeCleared
                ? () {
                    setState(() {
                      if (isSelected) {
                        _selectedItems.remove(item);
                      } else {
                        _selectedItems.add(item);
                      }
                    });
                  }
                : null,
          );
        },
      ),
      bottomNavigationBar: _selectedItems.isNotEmpty
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('已选择 ${_selectedItems.length} 个文件'),
              ),
            )
          : null,
    );
  }

  /// 删除选中的缓存项
  Future<void> _deleteSelectedItems() async {
    bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除选中的 ${_selectedItems.length} 个缓存文件吗？此操作无法撤销。'),
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
        for (final item in _selectedItems) {
          await cacheManager.clearCacheItem(item);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已删除 ${_selectedItems.length} 个缓存文件')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        debugPrint('Error deleting cache items: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除缓存文件失败: $e')));
        }
      }
    }
  }

  /// 获取分类名称
  String _getCategoryName(CacheCategory category) {
    switch (category) {
      case CacheCategory.audio:
        return '音频';
      case CacheCategory.image:
        return '图片';
      case CacheCategory.timeline:
        return '时间线';
      case CacheCategory.other:
        return '其他';
    }
  }

  /// 将字节数转换为可读格式
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
