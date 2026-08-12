import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/core/core.dart';
import '/src/core/services/misskey_image_cache_service.dart';
import '/src/core/services/misskey_image_cache_database.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

/// A network image widget with caching support and retry mechanism
/// 
/// 集成 SQLite 元数据缓存，支持：
/// - 本地文件缓存（使用现有 cacheManager）
/// - SQLite 元数据记录（URL、本地路径、关联UID、访问时间等）
/// - 可选的 UID 关联（用于发帖人标记和互动关系比对）
class RetryableNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  
  /// 可选的关联用户UID（用于头像等场景）
  final String? associatedUserId;
  
  /// 可选的关联帖子ID（用于帖子图片场景）
  final String? associatedNoteId;
  
  /// 可选的关联主机（用于多实例场景）
  final String? associatedHost;
  
  /// 缓存类型（默认为 postImage）
  final ImageCacheType cacheType;

  const RetryableNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.associatedUserId,
    this.associatedNoteId,
    this.associatedHost,
    this.cacheType = ImageCacheType.postImage,
  });

  @override
  State<RetryableNetworkImage> createState() => _RetryableNetworkImageState();
}

class _RetryableNetworkImageState extends State<RetryableNetworkImage> with WidgetsBindingObserver {
  String? _cachedPath;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _forceNetwork = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 首次加载逻辑：如果不是强制网络模式，则尝试缓存
    // 这里我们默认进入页面时为了稳定性，可以先检查一下缓存，
    // 但根据用户指令，如果是“进入时间线页面”这种场景，我们通过标志位控制。
    // 为了简单起见，我们直接按照指令：进入页面时直接执行第二次重点加载（网络）
    _forceNetwork = true;
    _checkAndCacheImage();
  }

  @override
  void didUpdateWidget(RetryableNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 URL 发生了变化（例如列表滚动复用或实时推送到新内容）
    if (oldWidget.url != widget.url) {
      if (mounted) {
        setState(() {
          _cachedPath = null;
          _retryCount = 0;
          _forceNetwork = true; // 新内容到来，直接全盘走网络
        });
        _checkAndCacheImage();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当 App 从后台切回前台时，强制使用网络加载，跳过缓存
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          _forceNetwork = true;
          _retryCount = 0; // 重置重试次数
        });
        _checkAndCacheImage();
      }
    }
  }

  Future<void> _checkAndCacheImage() async {
    // 如果已经开启了强制网络模式，我们仍然可以在后台悄悄下载缓存，
    // 但 UI 层将由 build 方法根据 _forceNetwork 决定渲染哪个
    if (_forceNetwork) {
      // 在强制网络模式下，我们也可以尝试异步更新一下缓存，但不等待它
      _updateCacheInBackground();
      return;
    }

    try {
      // 检查是否已缓存
      final isCached = await cacheManager.isFileCachedAndValid(
        widget.url,
        CacheCategory.image,
      );

      if (isCached) {
        // 从缓存获取路径
        final cachedPath = await cacheManager.getCacheFilePath(
          widget.url,
          CacheCategory.image,
        );
        if (mounted) {
          setState(() {
            _cachedPath = cachedPath;
          });
        }
      } else {
        await _updateCacheInBackground();
      }
    } catch (e) {
      logger.error('缓存图片基础检查失败: ${widget.url}', e);
      if (mounted) {
        setState(() {
          _forceNetwork = true;
        });
      }
    }
  }

  Future<void> _updateCacheInBackground() async {
    try {
      final cachedPath = await cacheManager.cacheFile(
        widget.url,
        CacheCategory.image,
      );
      
      // 记录到 SQLite 元数据（完全异步，不阻塞）
      if (cachedPath != null && mounted) {
        _recordToSQLite(cachedPath);
      }
      
      if (mounted && !_forceNetwork) {
        setState(() {
          _cachedPath = cachedPath;
        });
      }
    } catch (e) {
      // 这里的错误不再弹出，因为我们有网络加载保底
      logger.warning('后台更新缓存失败 (不影响显示): ${widget.url}');
    }
  }

  /// 记录缓存元数据到 SQLite（完全异步，不阻塞渲染）
  void _recordToSQLite(String localPath) {
    // 使用 Future.microtask 确保不阻塞当前帧渲染
    // SQLite 写入完全在后台执行，失败也不影响图片显示
    Future.microtask(() async {
      try {
        final cacheService = MisskeyImageCacheService();
        await cacheService.cacheImage(
          imageUrl: widget.url,
          cacheType: widget.cacheType,
          associatedUserId: widget.associatedUserId,
          associatedNoteId: widget.associatedNoteId,
          associatedHost: widget.associatedHost,
        );
      } catch (e) {
        logger.warning('SQLite 元数据记录失败: ${widget.url}');
      }
    });
  }

  Future<void> _retryLoading() async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      logger.info('触发第二次重点加载 (重试 $_retryCount/$_maxRetries): ${widget.url}');
      if (mounted) {
        setState(() {
          _forceNetwork = true;
          _cachedPath = null; // 清除缓存路径尝试，全盘走网络
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果强制使用网络，或者缓存路径为空，执行第二次重点加载（网络）
    if (_forceNetwork || _cachedPath == null) {
      return _buildNetworkImage();
    }

    // 否则尝试使用缓存加载（第一次尝试）
    return Image.file(
      File(_cachedPath!),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) {
        // 如果缓存加载失败（例如信号灯超时或文件损坏），立即切到网络加载
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_forceNetwork) {
            setState(() {
              _forceNetwork = true;
            });
          }
        });
        return _buildNetworkImage();
      },
    );
  }

  Widget _buildNetworkImage() {
    return Image.network(
      widget.url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: widget.width,
          height: widget.height ?? 200,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: CyaniLoadingIndicator(size: 24),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // 检查是否是 HandshakeException
        final errorStr = error.toString().toLowerCase();
        final isHandshakeError =
            errorStr.contains('handshake') ||
            errorStr.contains('connection terminated') ||
            errorStr.contains('connection closed');

        // 如果是握手错误，自动重试
        if (isHandshakeError && _retryCount < _maxRetries) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _retryLoading();
          });
        }

        // 检查是否是表情图片（小尺寸）
        final isEmojiSize =
            widget.width != null &&
            widget.width! <= 30 &&
            widget.height != null &&
            widget.height! <= 30;

        if (isEmojiSize) {
          // 对于表情图片，显示一个简单的错误图标
          return Container(
            width: widget.width,
            height: widget.height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.error_outline,
                size: widget.width! * 0.7,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          );
        } else {
          // 对于普通图片，显示完整的错误处理组件
          return Container(
            width: widget.width,
            height: widget.height ?? 150,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'image_unavailable'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _retryLoading,
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ),
          );
        }
      },
    );
  }
}
