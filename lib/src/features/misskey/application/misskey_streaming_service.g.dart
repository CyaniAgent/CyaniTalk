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
        isAutoDispose: true,
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
    r'64138cffe22f275c00d5ac28a8cdea9bc9a216b7';

abstract class _$MisskeyStreamingService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
