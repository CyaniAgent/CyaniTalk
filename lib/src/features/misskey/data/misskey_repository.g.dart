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
          AsyncValue<MisskeyRepository>,
          MisskeyRepository,
          FutureOr<MisskeyRepository>
        >
    with
        $FutureModifier<MisskeyRepository>,
        $FutureProvider<MisskeyRepository> {
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
  $FutureProviderElement<MisskeyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MisskeyRepository> create(Ref ref) {
    return misskeyRepository(ref);
  }
}

String _$misskeyRepositoryHash() => r'd2e4c81c240d424ef70d58b3cdcb9736a5ae898f';
