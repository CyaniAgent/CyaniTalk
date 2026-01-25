// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 提供FlutterSecureStorage实例的Riverpod提供者
///
/// 该提供者创建并返回一个FlutterSecureStorage实例，用于安全存储数据。

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

/// 提供FlutterSecureStorage实例的Riverpod提供者
///
/// 该提供者创建并返回一个FlutterSecureStorage实例，用于安全存储数据。

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  /// 提供FlutterSecureStorage实例的Riverpod提供者
  ///
  /// 该提供者创建并返回一个FlutterSecureStorage实例，用于安全存储数据。
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'a4f75721472cf77465bf47f759c90de5ca30856e';

/// 提供AuthRepository实例的Riverpod提供者
///
/// 该提供者创建并返回一个AuthRepository实例，用于处理账户信息的存储和检索。

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// 提供AuthRepository实例的Riverpod提供者
///
/// 该提供者创建并返回一个AuthRepository实例，用于处理账户信息的存储和检索。

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// 提供AuthRepository实例的Riverpod提供者
  ///
  /// 该提供者创建并返回一个AuthRepository实例，用于处理账户信息的存储和检索。
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'd0914b479f5647ec971241863e2451ee94c5bf63';
