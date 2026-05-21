// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationSettingsNotifier)
final notificationSettingsProvider = NotificationSettingsNotifierProvider._();

final class NotificationSettingsNotifierProvider
    extends
        $AsyncNotifierProvider<
          NotificationSettingsNotifier,
          NotificationSettings
        > {
  NotificationSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsNotifierHash();

  @$internal
  @override
  NotificationSettingsNotifier create() => NotificationSettingsNotifier();
}

String _$notificationSettingsNotifierHash() =>
    r'087e513c457c2430f543d927225dd3e75bccc294';

abstract class _$NotificationSettingsNotifier
    extends $AsyncNotifier<NotificationSettings> {
  FutureOr<NotificationSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<NotificationSettings>, NotificationSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationSettings>,
                NotificationSettings
              >,
              AsyncValue<NotificationSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
