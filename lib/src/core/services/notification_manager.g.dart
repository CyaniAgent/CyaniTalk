// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationManager)
final notificationManagerProvider = NotificationManagerProvider._();

final class NotificationManagerProvider
    extends
        $FunctionalProvider<
          NotificationManager,
          NotificationManager,
          NotificationManager
        >
    with $Provider<NotificationManager> {
  NotificationManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationManagerHash();

  @$internal
  @override
  $ProviderElement<NotificationManager> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationManager create(Ref ref) {
    return notificationManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationManager>(value),
    );
  }
}

String _$notificationManagerHash() =>
    r'e94f2710cbae0fb35ad4578203f0ec86ace4b94f';
