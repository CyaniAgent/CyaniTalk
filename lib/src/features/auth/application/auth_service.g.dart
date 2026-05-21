// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 认证服务类
///
/// 负责处理用户认证流程，包括Misskey的MiAuth流程，
/// 管理认证状态和账户信息。

@ProviderFor(AuthService)
final authServiceProvider = AuthServiceProvider._();

/// 认证服务类
///
/// 负责处理用户认证流程，包括Misskey的MiAuth流程，
/// 管理认证状态和账户信息。
final class AuthServiceProvider
    extends $AsyncNotifierProvider<AuthService, List<Account>> {
  /// 认证服务类
  ///
  /// 负责处理用户认证流程，包括Misskey的MiAuth流程，
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

String _$authServiceHash() => r'5f65a413942a1cf31f03aeb5b6c03ecd9702309d';

/// 认证服务类
///
/// 负责处理用户认证流程，包括Misskey的MiAuth流程，
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

/// 选中的Misskey账户提供者
///
/// 管理当前选中的Misskey账户，支持账户切换和自动选择逻辑。

@ProviderFor(SelectedMisskeyAccount)
final selectedMisskeyAccountProvider = SelectedMisskeyAccountProvider._();

/// 选中的Misskey账户提供者
///
/// 管理当前选中的Misskey账户，支持账户切换和自动选择逻辑。
final class SelectedMisskeyAccountProvider
    extends $AsyncNotifierProvider<SelectedMisskeyAccount, Account?> {
  /// 选中的Misskey账户提供者
  ///
  /// 管理当前选中的Misskey账户，支持账户切换和自动选择逻辑。
  SelectedMisskeyAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedMisskeyAccountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedMisskeyAccountHash();

  @$internal
  @override
  SelectedMisskeyAccount create() => SelectedMisskeyAccount();
}

String _$selectedMisskeyAccountHash() =>
    r'419b8a883b4c1d0f151fe7300b970ed2bbbd77d5';

/// 选中的Misskey账户提供者
///
/// 管理当前选中的Misskey账户，支持账户切换和自动选择逻辑。

abstract class _$SelectedMisskeyAccount extends $AsyncNotifier<Account?> {
  FutureOr<Account?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Account?>, Account?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Account?>, Account?>,
              AsyncValue<Account?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
