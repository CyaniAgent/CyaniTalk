import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/core/core.dart';

/// A network image widget with caching support and retry mechanism
class RetryableNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  const RetryableNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<RetryableNetworkImage> createState() => _RetryableNetworkImageState();
}

class _RetryableNetworkImageState extends State<RetryableNetworkImage> {
  String? _cachedPath;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    // 异步进行缓存检查和下载
    _checkAndCacheImage();
  }

  Future<void> _checkAndCacheImage() async {
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
        // 下载并缓存
        final cachedPath = await cacheManager.cacheFile(
          widget.url,
          CacheCategory.image,
        );
        if (mounted) {
          setState(() {
            _cachedPath = cachedPath;
          });
        }
      }
    } catch (e) {
      logger.error('缓存图片失败: ${widget.url}', e);
    }
  }

  Future<void> _retryLoading() async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      logger.info('重试加载图片 ($_retryCount/$_maxRetries): ${widget.url}');
      await _checkAndCacheImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果有缓存，使用缓存加载
    if (_cachedPath != null) {
      return Image.file(
        File(_cachedPath!),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          // 如果缓存加载失败，回退到网络加载
          return _buildNetworkImage();
        },
      );
    }

    // 否则直接从网络加载
    return _buildNetworkImage();
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
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
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
                ElevatedButton(
                  onPressed: _retryLoading,
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
