// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_search_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 全局搜索服务
///
/// 提供跨平台搜索功能，支持在Misskey和Flarum平台上搜索内容。

@ProviderFor(GlobalSearch)
final globalSearchProvider = GlobalSearchProvider._();

/// 全局搜索服务
///
/// 提供跨平台搜索功能，支持在Misskey和Flarum平台上搜索内容。
final class GlobalSearchProvider extends $NotifierProvider<GlobalSearch, void> {
  /// 全局搜索服务
  ///
  /// 提供跨平台搜索功能，支持在Misskey和Flarum平台上搜索内容。
  GlobalSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalSearchHash();

  @$internal
  @override
  GlobalSearch create() => GlobalSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$globalSearchHash() => r'4c9bfee87e4305d4bf0c26f1056bf9030b790b4a';

/// 全局搜索服务
///
/// 提供跨平台搜索功能，支持在Misskey和Flarum平台上搜索内容。

abstract class _$GlobalSearch extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
