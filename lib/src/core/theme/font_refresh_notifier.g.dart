// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_refresh_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 字体刷新状态管理器
/// 用于触发全局字体更新

@ProviderFor(FontRefreshNotifier)
final fontRefreshProvider = FontRefreshNotifierProvider._();

/// 字体刷新状态管理器
/// 用于触发全局字体更新
final class FontRefreshNotifierProvider
    extends $NotifierProvider<FontRefreshNotifier, bool> {
  /// 字体刷新状态管理器
  /// 用于触发全局字体更新
  FontRefreshNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fontRefreshProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fontRefreshNotifierHash();

  @$internal
  @override
  FontRefreshNotifier create() => FontRefreshNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$fontRefreshNotifierHash() =>
    r'19d39a0786596b6ab2c2580ff27ec10db1f06196';

/// 字体刷新状态管理器
/// 用于触发全局字体更新

abstract class _$FontRefreshNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
