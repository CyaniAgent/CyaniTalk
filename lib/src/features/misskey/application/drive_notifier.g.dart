// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MisskeyDriveNotifier)
final misskeyDriveProvider = MisskeyDriveNotifierProvider._();

final class MisskeyDriveNotifierProvider
    extends $AsyncNotifierProvider<MisskeyDriveNotifier, DriveState> {
  MisskeyDriveNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyDriveProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyDriveNotifierHash();

  @$internal
  @override
  MisskeyDriveNotifier create() => MisskeyDriveNotifier();
}

String _$misskeyDriveNotifierHash() =>
    r'b1a2e6b89217ba601f8dd320d79fae240dc43ea9';

abstract class _$MisskeyDriveNotifier extends $AsyncNotifier<DriveState> {
  FutureOr<DriveState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DriveState>, DriveState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DriveState>, DriveState>,
              AsyncValue<DriveState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
