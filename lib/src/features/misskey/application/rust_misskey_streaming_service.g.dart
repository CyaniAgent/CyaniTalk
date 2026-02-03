// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rust_misskey_streaming_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RustMisskeyStreamingService)
final rustMisskeyStreamingServiceProvider =
    RustMisskeyStreamingServiceProvider._();

final class RustMisskeyStreamingServiceProvider
    extends $NotifierProvider<RustMisskeyStreamingService, void> {
  RustMisskeyStreamingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rustMisskeyStreamingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rustMisskeyStreamingServiceHash();

  @$internal
  @override
  RustMisskeyStreamingService create() => RustMisskeyStreamingService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$rustMisskeyStreamingServiceHash() =>
    r'6cb7ac517bdfb5f7779ce53de8960a60029c8f41';

abstract class _$RustMisskeyStreamingService extends $Notifier<void> {
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
