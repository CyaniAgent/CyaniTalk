import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/src/core/services/misskey_image_cache_service.dart';

/// CachedMisskeyAvatar 组件
///
/// 带 SQLite 缓存的用户头像组件，支持：
/// 1. 永久缓存头像到本地
/// 2. SQLite 记录用户 UID 关联
/// 3. 发帖人标记（对比当前登录用户 UID）
/// 4. 互动关系标识
class CachedMisskeyAvatar extends ConsumerStatefulWidget {
  final String userId;
  final String avatarUrl;
  final String? host;
  final double radius;
  final String? currentUserId;
  final bool showIsMeBadge;
  final VoidCallback? onTap;

  const CachedMisskeyAvatar({
    super.key,
    required this.userId,
    required this.avatarUrl,
    this.host,
    this.radius = 20,
    this.currentUserId,
    this.showIsMeBadge = true,
    this.onTap,
  });

  @override
  ConsumerState<CachedMisskeyAvatar> createState() =>
      _CachedMisskeyAvatarState();
}

class _CachedMisskeyAvatarState extends ConsumerState<CachedMisskeyAvatar> {
  String? _localPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void didUpdateWidget(covariant CachedMisskeyAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl ||
        oldWidget.userId != widget.userId) {
      _loadAvatar();
    }
  }

  Future<void> _loadAvatar() async {
    setState(() => _isLoading = true);

    final cacheService = ref.read(misskeyImageCacheServiceProvider);
    final path = await cacheService.getAvatarPath(
      userId: widget.userId,
      avatarUrl: widget.avatarUrl,
      host: widget.host,
    );

    if (mounted) {
      setState(() {
        _localPath = path;
        _isLoading = false;
      });
    }
  }

  bool get _isMe =>
      widget.showIsMeBadge &&
      widget.currentUserId != null &&
      widget.userId == widget.currentUserId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundImage: _buildImageProvider(),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          if (_isMe)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider? _buildImageProvider() {
    final path = _localPath;
    if (path == null) return null;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return null;
  }
}

/// 简单的缓存头像加载器（用于列表等性能敏感场景）
class CachedAvatarImage extends ConsumerWidget {
  final String userId;
  final String avatarUrl;
  final String? host;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CachedAvatarImage({
    super.key,
    required this.userId,
    required this.avatarUrl,
    this.host,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheService = ref.watch(misskeyImageCacheServiceProvider);

    return FutureBuilder<String?>(
      future: cacheService.getCachedPath(avatarUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final file = File(snapshot.data!);
          if (file.existsSync()) {
            return Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
            );
          }
        }

        // 未缓存时使用网络图片，并后台预取
        cacheService.prefetchAvatar(
          userId: userId,
          avatarUrl: avatarUrl,
          host: host,
        );

        return Image.network(
          avatarUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.person_outline,
                size: width != null ? width! * 0.6 : 24,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          },
        );
      },
    );
  }
}
