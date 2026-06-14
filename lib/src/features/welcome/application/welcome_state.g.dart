// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WelcomeStep)
final welcomeStepProvider = WelcomeStepProvider._();

final class WelcomeStepProvider extends $NotifierProvider<WelcomeStep, int> {
  WelcomeStepProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'welcomeStepProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$welcomeStepHash();

  @$internal
  @override
  WelcomeStep create() => WelcomeStep();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$welcomeStepHash() => r'8ed658c075d8c0b8e6ea998c2f855d60d6861f35';

abstract class _$WelcomeStep extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(WelcomeCompleted)
final welcomeCompletedProvider = WelcomeCompletedProvider._();

final class WelcomeCompletedProvider
    extends $AsyncNotifierProvider<WelcomeCompleted, bool> {
  WelcomeCompletedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'welcomeCompletedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$welcomeCompletedHash();

  @$internal
  @override
  WelcomeCompleted create() => WelcomeCompleted();
}

String _$welcomeCompletedHash() => r'9c5f51ec12398685160717914348ab17ddc8f164';

abstract class _$WelcomeCompleted extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SetupStatus)
final setupStatusProvider = SetupStatusProvider._();

final class SetupStatusProvider
    extends $NotifierProvider<SetupStatus, String?> {
  SetupStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setupStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setupStatusHash();

  @$internal
  @override
  SetupStatus create() => SetupStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$setupStatusHash() => r'bc351bb9a6ee39386beaafc8843bd5035e76e2a8';

abstract class _$SetupStatus extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
