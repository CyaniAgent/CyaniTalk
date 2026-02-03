import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cyanitalk/src/core/utils/cache_manager.dart';

/// 缓存设置页面组件
class CacheSettingsPage extends StatefulWidget {
  const CacheSettingsPage({super.key});

  @override
  State<CacheSettingsPage> createState() => _CacheSettingsPageState();
}

class _CacheSettingsPageState extends State<CacheSettingsPage> {
  String? _cachePath;
  int _cacheSize = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCacheSettings();
  }

  /// 加载缓存设置
  Future<void> _loadCacheSettings() async {
    try {
      final cacheDir = await cacheManager.getCacheDirectory();
      final cacheSize = await cacheManager.getCacheSize();
      
      if (mounted) {
        setState(() {
          _cachePath = cacheDir.path;
          _cacheSize = cacheSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('Error loading cache settings: $e');
      }
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
        
        // 重新加载设置
        final cacheDir = await cacheManager.getCacheDirectory();
        final cacheSize = await cacheManager.getCacheSize();
        
        setState(() {
          _cachePath = cacheDir.path;
          _cacheSize = cacheSize;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('缓存目录已更新')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error selecting cache directory: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择缓存目录失败: $e')),
        );
      }
    }
  }

  /// 清除缓存
  Future<void> _clearCache() async {
    bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认清除缓存'),
        content: Text('确定要清除所有缓存文件吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('确定'),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await cacheManager.clearCache();
        
        // 重新加载缓存大小
        final newCacheSize = await cacheManager.getCacheSize();
        
        if (mounted) {
          setState(() {
            _cacheSize = newCacheSize;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('缓存已清除')),
          );
        }
      } catch (e) {
        debugPrint('Error clearing cache: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('清除缓存失败: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('缓存设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 缓存路径设置
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _cachePath ?? '未知',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _selectCustomCacheDirectory,
                                child: Text('更改'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 缓存管理
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '缓存管理',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('缓存大小'),
                              Text(_formatBytes(_cacheSize)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _clearCache,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('清除缓存'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 说明信息
                  Text(
                    '缓存用于存储音频、视频、图片等多媒体文件，以提升加载速度并减少网络流量消耗。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }

  /// 将字节数转换为可读格式
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}