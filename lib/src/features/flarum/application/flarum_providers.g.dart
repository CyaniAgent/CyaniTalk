// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flarum_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(flarumApi)
final flarumApiProvider = FlarumApiProvider._();

final class FlarumApiProvider
    extends $FunctionalProvider<FlarumApi, FlarumApi, FlarumApi>
    with $Provider<FlarumApi> {
  FlarumApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flarumApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flarumApiHash();

  @$internal
  @override
  $ProviderElement<FlarumApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlarumApi create(Ref ref) {
    return flarumApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlarumApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlarumApi>(value),
    );
  }
}

String _$flarumApiHash() => r'0b906ab670fafb28b2d983098d525705ba24ab74';

@ProviderFor(flarumRepository)
final flarumRepositoryProvider = FlarumRepositoryProvider._();

final class FlarumRepositoryProvider
    extends
        $FunctionalProvider<
          FlarumRepository,
          FlarumRepository,
          FlarumRepository
        >
    with $Provider<FlarumRepository> {
  FlarumRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flarumRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flarumRepositoryHash();

  @$internal
  @override
  $ProviderElement<FlarumRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlarumRepository create(Ref ref) {
    return flarumRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlarumRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlarumRepository>(value),
    );
  }
}

String _$flarumRepositoryHash() => r'eeaaaa107775358c8d6cfba5efe9015d65516f9a';

@ProviderFor(forumInfo)
final forumInfoProvider = ForumInfoProvider._();

final class ForumInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<ForumInfo>,
          ForumInfo,
          FutureOr<ForumInfo>
        >
    with $FutureModifier<ForumInfo>, $FutureProvider<ForumInfo> {
  ForumInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forumInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forumInfoHash();

  @$internal
  @override
  $FutureProviderElement<ForumInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ForumInfo> create(Ref ref) {
    return forumInfo(ref);
  }
}

String _$forumInfoHash() => r'5500ecc9b85eac26cf4761e6dfa7a7580bf2afb8';

@ProviderFor(flarumCurrentUser)
final flarumCurrentUserProvider = FlarumCurrentUserProvider._();

final class FlarumCurrentUserProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, FutureOr<User?>>
    with $FutureModifier<User?>, $FutureProvider<User?> {
  FlarumCurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flarumCurrentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flarumCurrentUserHash();

  @$internal
  @override
  $FutureProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<User?> create(Ref ref) {
    return flarumCurrentUser(ref);
  }
}

String _$flarumCurrentUserHash() => r'6daf552a4ea4c91088cc1d758ca65b7670d411a3';

@ProviderFor(discussions)
final discussionsProvider = DiscussionsProvider._();

final class DiscussionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Discussion>>,
          List<Discussion>,
          FutureOr<List<Discussion>>
        >
    with $FutureModifier<List<Discussion>>, $FutureProvider<List<Discussion>> {
  DiscussionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discussionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discussionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Discussion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Discussion>> create(Ref ref) {
    return discussions(ref);
  }
}

String _$discussionsHash() => r'b079a56ec06f640bcbd87192753867b3a3b58b7f';

@ProviderFor(flarumNotifications)
final flarumNotificationsProvider = FlarumNotificationsProvider._();

final class FlarumNotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FlarumNotification>>,
          List<FlarumNotification>,
          FutureOr<List<FlarumNotification>>
        >
    with
        $FutureModifier<List<FlarumNotification>>,
        $FutureProvider<List<FlarumNotification>> {
  FlarumNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flarumNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flarumNotificationsHash();

  @$internal
  @override
  $FutureProviderElement<List<FlarumNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FlarumNotification>> create(Ref ref) {
    return flarumNotifications(ref);
  }
}

String _$flarumNotificationsHash() =>
    r'5b9f99d986fb53ebf896b97ccd373b37deaa1333';
