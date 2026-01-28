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
          MisskeyRepository,
          MisskeyRepository,
          MisskeyRepository
        >
    with $Provider<MisskeyRepository> {
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
  $ProviderElement<MisskeyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MisskeyRepository create(Ref ref) {
    return misskeyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MisskeyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MisskeyRepository>(value),
    );
  }
}

String _$misskeyRepositoryHash() => r'77eaa842eeabae2a47450647255027b1731fef9d';
