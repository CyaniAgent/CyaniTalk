// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_form_components.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 登录表单控制器 (当前未接入 login_form.dart)
///
/// 管理登录流程的步骤、表单数据和加载状态。

@ProviderFor(LoginFormController)
final loginFormControllerProvider = LoginFormControllerProvider._();

/// 登录表单控制器 (当前未接入 login_form.dart)
///
/// 管理登录流程的步骤、表单数据和加载状态。
final class LoginFormControllerProvider
    extends $NotifierProvider<LoginFormController, LoginFormData> {
  /// 登录表单控制器 (当前未接入 login_form.dart)
  ///
  /// 管理登录流程的步骤、表单数据和加载状态。
  LoginFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginFormControllerHash();

  @$internal
  @override
  LoginFormController create() => LoginFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginFormData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginFormData>(value),
    );
  }
}

String _$loginFormControllerHash() =>
    r'c3138c7ad727dff2290eca2e313a30491cb1b647';

/// 登录表单控制器 (当前未接入 login_form.dart)
///
/// 管理登录流程的步骤、表单数据和加载状态。

abstract class _$LoginFormController extends $Notifier<LoginFormData> {
  LoginFormData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoginFormData, LoginFormData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginFormData, LoginFormData>,
              LoginFormData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
