import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

/// A network image widget with automatic retry on failure
class RetryableNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final int maxRetries;
  final double? width;
  final double? height;

  const RetryableNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.maxRetries = 3,
    this.width,
    this.height,
  });

  @override
  State<RetryableNetworkImage> createState() => _RetryableNetworkImageState();
}

class _RetryableNetworkImageState extends State<RetryableNetworkImage> {
  int _retryCount = 0;
  String? _imageKey;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _imageKey = '${widget.url}_$_retryCount';
  }

  void _retry() {
    if (mounted && _retryCount < widget.maxRetries) {
      setState(() {
        _retryCount++;
        _imageKey = '${widget.url}_$_retryCount';
      });
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 ImageCacheConfig 计算缓存尺寸
    final (cacheWidth, cacheHeight) = ImageCacheConfig.calculateCacheSize(
      widget.width,
      widget.height,
    );

    return CachedNetworkImage(
      imageUrl: widget.url,
      key: ValueKey(_imageKey),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      maxWidthDiskCache: cacheWidth,
      maxHeightDiskCache: cacheHeight,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Container(
          width: widget.width,
          height: widget.height ?? 200,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              value: downloadProgress.totalSize != null
                  ? downloadProgress.downloaded / downloadProgress.totalSize!
                  : null,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        // Auto-retry on first few failures
        if (_retryCount < widget.maxRetries) {
          _retryTimer = Timer(Duration(seconds: _retryCount + 1), _retry);
        }

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
                _retryCount >= widget.maxRetries
                    ? Icons.broken_image_outlined
                    : Icons.refresh,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                _retryCount >= widget.maxRetries
                    ? 'image_unavailable'.tr()
                    : 'image_retrying'.tr(
                        namedArgs: {
                          'retryCount': _retryCount.toString(),
                          'maxRetries': widget.maxRetries.toString(),
                        },
                      ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              if (_retryCount < widget.maxRetries)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        );
      },
      // 添加超时设置
      httpHeaders: {
        'Cache-Control': 'max-age=86400', // 24小时缓存
      },
    );
  }
}

/// 图片缓存配置
class ImageCacheConfig {
  /// 最大缓存宽度
  static const int maxCacheWidth = 800;

  /// 最大缓存高度
  static const int maxCacheHeight = 800;

  /// 默认缓存宽度
  static const int defaultCacheWidth = 400;

  /// 默认缓存高度
  static const int defaultCacheHeight = 400;

  /// 计算合适的缓存尺寸
  static (int, int) calculateCacheSize(double? width, double? height) {
    if (width != null && height != null) {
      // 检查是否为有效数字
      if (width.isFinite && height.isFinite) {
        final cacheWidth = width.toInt().clamp(1, maxCacheWidth);
        final cacheHeight = height.toInt().clamp(1, maxCacheHeight);
        return (cacheWidth, cacheHeight);
      }
    }
    return (defaultCacheWidth, defaultCacheHeight);
  }
}
