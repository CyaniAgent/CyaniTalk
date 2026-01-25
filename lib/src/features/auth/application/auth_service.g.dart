// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 认证服务类
///
/// 负责处理用户认证流程，包括Misskey的MiAuth流程和Flarum的账户链接功能，
/// 管理认证状态和账户信息。

@ProviderFor(AuthService)
final authServiceProvider = AuthServiceProvider._();

/// 认证服务类
///
/// 负责处理用户认证流程，包括Misskey的MiAuth流程和Flarum的账户链接功能，
/// 管理认证状态和账户信息。
final class AuthServiceProvider
    extends $AsyncNotifierProvider<AuthService, List<Account>> {
  /// 认证服务类
  ///
  /// 负责处理用户认证流程，包括Misskey的MiAuth流程和Flarum的账户链接功能，
  /// 管理认证状态和账户信息。
  AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  AuthService create() => AuthService();
}

String _$authServiceHash() => r'b4292e98f5965bffe71f564229657baa5c953fff';

/// 认证服务类
///
/// 负责处理用户认证流程，包括Misskey的MiAuth流程和Flarum的账户链接功能，
/// 管理认证状态和账户信息。

abstract class _$AuthService extends $AsyncNotifier<List<Account>> {
  FutureOr<List<Account>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Account>>, List<Account>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Account>>, List<Account>>,
              AsyncValue<List<Account>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
