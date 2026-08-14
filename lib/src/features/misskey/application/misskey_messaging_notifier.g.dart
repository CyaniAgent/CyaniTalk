// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_messaging_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MisskeyMessagingHistoryNotifier)
final misskeyMessagingHistoryProvider =
    MisskeyMessagingHistoryNotifierProvider._();

final class MisskeyMessagingHistoryNotifierProvider
    extends
        $AsyncNotifierProvider<
          MisskeyMessagingHistoryNotifier,
          List<MessagingMessage>
        > {
  MisskeyMessagingHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyMessagingHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyMessagingHistoryNotifierHash();

  @$internal
  @override
  MisskeyMessagingHistoryNotifier create() => MisskeyMessagingHistoryNotifier();
}

String _$misskeyMessagingHistoryNotifierHash() =>
    r'8472e3262cf52d32777968f4336b63125bd8ff1c';

abstract class _$MisskeyMessagingHistoryNotifier
    extends $AsyncNotifier<List<MessagingMessage>> {
  FutureOr<List<MessagingMessage>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<MessagingMessage>>, List<MessagingMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MessagingMessage>>,
                List<MessagingMessage>
              >,
              AsyncValue<List<MessagingMessage>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(MisskeyMessagingNotifier)
final misskeyMessagingProvider = MisskeyMessagingNotifierFamily._();

final class MisskeyMessagingNotifierProvider
    extends
        $AsyncNotifierProvider<
          MisskeyMessagingNotifier,
          List<MessagingMessage>
        > {
  MisskeyMessagingNotifierProvider._({
    required MisskeyMessagingNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'misskeyMessagingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$misskeyMessagingNotifierHash();

  @override
  String toString() {
    return r'misskeyMessagingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MisskeyMessagingNotifier create() => MisskeyMessagingNotifier();

  @override
  bool operator ==(Object other) {
    return other is MisskeyMessagingNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$misskeyMessagingNotifierHash() =>
    r'01c495607c3961e03d8a2d4c386e028a033bc82f';

final class MisskeyMessagingNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MisskeyMessagingNotifier,
          AsyncValue<List<MessagingMessage>>,
          List<MessagingMessage>,
          FutureOr<List<MessagingMessage>>,
          String
        > {
  MisskeyMessagingNotifierFamily._()
    : super(
        retry: null,
        name: r'misskeyMessagingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MisskeyMessagingNotifierProvider call(String userId) =>
      MisskeyMessagingNotifierProvider._(argument: userId, from: this);

  @override
  String toString() => r'misskeyMessagingProvider';
}

abstract class _$MisskeyMessagingNotifier
    extends $AsyncNotifier<List<MessagingMessage>> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<List<MessagingMessage>> build(String userId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<MessagingMessage>>, List<MessagingMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MessagingMessage>>,
                List<MessagingMessage>
              >,
              AsyncValue<List<MessagingMessage>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(MisskeyChatRoomNotifier)
final misskeyChatRoomProvider = MisskeyChatRoomNotifierFamily._();

final class MisskeyChatRoomNotifierProvider
    extends
        $AsyncNotifierProvider<
          MisskeyChatRoomNotifier,
          List<MessagingMessage>
        > {
  MisskeyChatRoomNotifierProvider._({
    required MisskeyChatRoomNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'misskeyChatRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$misskeyChatRoomNotifierHash();

  @override
  String toString() {
    return r'misskeyChatRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MisskeyChatRoomNotifier create() => MisskeyChatRoomNotifier();

  @override
  bool operator ==(Object other) {
    return other is MisskeyChatRoomNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$misskeyChatRoomNotifierHash() =>
    r'e4614a19776e71ac8d7694b3f1777ac6fc9dac1d';

final class MisskeyChatRoomNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MisskeyChatRoomNotifier,
          AsyncValue<List<MessagingMessage>>,
          List<MessagingMessage>,
          FutureOr<List<MessagingMessage>>,
          String
        > {
  MisskeyChatRoomNotifierFamily._()
    : super(
        retry: null,
        name: r'misskeyChatRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MisskeyChatRoomNotifierProvider call(String roomId) =>
      MisskeyChatRoomNotifierProvider._(argument: roomId, from: this);

  @override
  String toString() => r'misskeyChatRoomProvider';
}

abstract class _$MisskeyChatRoomNotifier
    extends $AsyncNotifier<List<MessagingMessage>> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  FutureOr<List<MessagingMessage>> build(String roomId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<MessagingMessage>>, List<MessagingMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MessagingMessage>>,
                List<MessagingMessage>
              >,
              AsyncValue<List<MessagingMessage>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
