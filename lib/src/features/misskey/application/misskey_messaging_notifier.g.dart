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
    r'4e5c20e535c2a098f1a7170c24269f13f1e98a33';

abstract class _$MisskeyMessagingHistoryNotifier
    extends $AsyncNotifier<List<MessagingMessage>> {
  FutureOr<List<MessagingMessage>> build();
  @$mustCallSuper
  @override
  void runBuild() {
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
    element.handleCreate(ref, build);
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
    r'4f9f022e2d464b5ddfb85a180401541f79191205';

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
  void runBuild() {
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
    element.handleCreate(ref, () => build(_$args));
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
    r'5061a7b81a2cb134e5ae38e3695d09e55155d2b1';

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
  void runBuild() {
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
    element.handleCreate(ref, () => build(_$args));
  }
}
