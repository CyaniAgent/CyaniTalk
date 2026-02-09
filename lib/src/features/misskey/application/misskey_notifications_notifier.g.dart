// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_notifications_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MisskeyNotificationsNotifier)
final misskeyNotificationsProvider = MisskeyNotificationsNotifierProvider._();

final class MisskeyNotificationsNotifierProvider
    extends
        $AsyncNotifierProvider<
          MisskeyNotificationsNotifier,
          List<MisskeyNotification>
        > {
  MisskeyNotificationsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyNotificationsNotifierHash();

  @$internal
  @override
  MisskeyNotificationsNotifier create() => MisskeyNotificationsNotifier();
}

String _$misskeyNotificationsNotifierHash() =>
    r'd8709736ff2b4344de16cfd2323e46ebd77bea84';

abstract class _$MisskeyNotificationsNotifier
    extends $AsyncNotifier<List<MisskeyNotification>> {
  FutureOr<List<MisskeyNotification>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MisskeyNotification>>,
              List<MisskeyNotification>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MisskeyNotification>>,
                List<MisskeyNotification>
              >,
              AsyncValue<List<MisskeyNotification>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
