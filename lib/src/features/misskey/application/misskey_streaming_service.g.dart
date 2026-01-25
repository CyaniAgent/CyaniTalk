// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_streaming_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MisskeyStreamingService)
final misskeyStreamingServiceProvider = MisskeyStreamingServiceProvider._();

final class MisskeyStreamingServiceProvider
    extends $NotifierProvider<MisskeyStreamingService, void> {
  MisskeyStreamingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyStreamingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyStreamingServiceHash();

  @$internal
  @override
  MisskeyStreamingService create() => MisskeyStreamingService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$misskeyStreamingServiceHash() =>
    r'cdd9cc9929aa8c7f40b7074deab7130980d8c428';

abstract class _$MisskeyStreamingService extends $Notifier<void> {
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
