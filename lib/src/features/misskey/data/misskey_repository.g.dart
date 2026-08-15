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
          AsyncValue<IMisskeyRepository>,
          IMisskeyRepository,
          FutureOr<IMisskeyRepository>
        >
    with
        $FutureModifier<IMisskeyRepository>,
        $FutureProvider<IMisskeyRepository> {
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
  $FutureProviderElement<IMisskeyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IMisskeyRepository> create(Ref ref) {
    return misskeyRepository(ref);
  }
}

String _$misskeyRepositoryHash() => r'22b0cbef4a8616323924b848ddc7232dd63a9d34';
