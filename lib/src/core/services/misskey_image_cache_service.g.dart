// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_image_cache_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Misskey 图片缓存服务 Provider

@ProviderFor(misskeyImageCacheService)
final misskeyImageCacheServiceProvider = MisskeyImageCacheServiceProvider._();

/// Misskey 图片缓存服务 Provider

final class MisskeyImageCacheServiceProvider
    extends
        $FunctionalProvider<
          MisskeyImageCacheService,
          MisskeyImageCacheService,
          MisskeyImageCacheService
        >
    with $Provider<MisskeyImageCacheService> {
  /// Misskey 图片缓存服务 Provider
  MisskeyImageCacheServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyImageCacheServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyImageCacheServiceHash();

  @$internal
  @override
  $ProviderElement<MisskeyImageCacheService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MisskeyImageCacheService create(Ref ref) {
    return misskeyImageCacheService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MisskeyImageCacheService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MisskeyImageCacheService>(value),
    );
  }
}

String _$misskeyImageCacheServiceHash() =>
    r'952f9135400c3103a5f9d9dbb330a29631941a9d';
