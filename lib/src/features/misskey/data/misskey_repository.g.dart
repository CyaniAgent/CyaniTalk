// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(misskeyRepository)
final misskeyRepositoryProvider = MisskeyRepositoryProvider._();

final class MisskeyRepositoryProvider
    extends
        $FunctionalProvider<
          MisskeyRepository?,
          MisskeyRepository?,
          MisskeyRepository?
        >
    with $Provider<MisskeyRepository?> {
  MisskeyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyRepositoryHash();

  @$internal
  @override
  $ProviderElement<MisskeyRepository?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MisskeyRepository? create(Ref ref) {
    return misskeyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MisskeyRepository? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MisskeyRepository?>(value),
    );
  }
}

<<<<<<< HEAD
String _$misskeyRepositoryHash() => r'8031b79c01b7c452771bf9ec50d3d9512c4c7f12';
=======
String _$misskeyRepositoryHash() => r'8d0039eed905ac839734facddb559d0dbd895fba';
>>>>>>> 261e8f5a782bb23e629bbff063be5bc20034fbcc
