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

String _$authServiceHash() => r'b44b56974ae0c82cf7dbc275d629200af44fb983';

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
    r'9148219d173f5c19bf18c3327a427fe61325958c';

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

/// 选中的Flarum账户提供者
///
/// 管理当前选中的Flarum账户，支持账户切换和自动选择逻辑。

@ProviderFor(SelectedFlarumAccount)
final selectedFlarumAccountProvider = SelectedFlarumAccountProvider._();

/// 选中的Flarum账户提供者
///
/// 管理当前选中的Flarum账户，支持账户切换和自动选择逻辑。
final class SelectedFlarumAccountProvider
    extends $AsyncNotifierProvider<SelectedFlarumAccount, Account?> {
  /// 选中的Flarum账户提供者
  ///
  /// 管理当前选中的Flarum账户，支持账户切换和自动选择逻辑。
  SelectedFlarumAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFlarumAccountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFlarumAccountHash();

  @$internal
  @override
  SelectedFlarumAccount create() => SelectedFlarumAccount();
}

String _$selectedFlarumAccountHash() =>
    r'0c24a685adc24bd9fccbfd47780ee196a3a2f3e9';

/// 选中的Flarum账户提供者
///
/// 管理当前选中的Flarum账户，支持账户切换和自动选择逻辑。

abstract class _$SelectedFlarumAccount extends $AsyncNotifier<Account?> {
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
