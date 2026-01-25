// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MisskeyTimelineNotifier)
final misskeyTimelineProvider = MisskeyTimelineNotifierFamily._();

final class MisskeyTimelineNotifierProvider
    extends $AsyncNotifierProvider<MisskeyTimelineNotifier, List<Note>> {
  MisskeyTimelineNotifierProvider._({
    required MisskeyTimelineNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'misskeyTimelineProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$misskeyTimelineNotifierHash();

  @override
  String toString() {
    return r'misskeyTimelineProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MisskeyTimelineNotifier create() => MisskeyTimelineNotifier();

  @override
  bool operator ==(Object other) {
    return other is MisskeyTimelineNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$misskeyTimelineNotifierHash() =>
    r'57f3f0436dd17aa2026f935f531188bdbb870dc6';

final class MisskeyTimelineNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MisskeyTimelineNotifier,
          AsyncValue<List<Note>>,
          List<Note>,
          FutureOr<List<Note>>,
          String
        > {
  MisskeyTimelineNotifierFamily._()
    : super(
        retry: null,
        name: r'misskeyTimelineProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MisskeyTimelineNotifierProvider call(String type) =>
      MisskeyTimelineNotifierProvider._(argument: type, from: this);

  @override
  String toString() => r'misskeyTimelineProvider';
}

abstract class _$MisskeyTimelineNotifier extends $AsyncNotifier<List<Note>> {
  late final _$args = ref.$arg as String;
  String get type => _$args;

  FutureOr<List<Note>> build(String type);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Note>>, List<Note>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Note>>, List<Note>>,
              AsyncValue<List<Note>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(MisskeyChannelsNotifier)
final misskeyChannelsProvider = MisskeyChannelsNotifierProvider._();

final class MisskeyChannelsNotifierProvider
    extends $AsyncNotifierProvider<MisskeyChannelsNotifier, List<Channel>> {
  MisskeyChannelsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyChannelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyChannelsNotifierHash();

  @$internal
  @override
  MisskeyChannelsNotifier create() => MisskeyChannelsNotifier();
}

String _$misskeyChannelsNotifierHash() =>
    r'a2e71845694e14c494d85fd7b11e9ba72ad7ea94';

abstract class _$MisskeyChannelsNotifier extends $AsyncNotifier<List<Channel>> {
  FutureOr<List<Channel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Channel>>, List<Channel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Channel>>, List<Channel>>,
              AsyncValue<List<Channel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MisskeyChannelTimelineNotifier)
final misskeyChannelTimelineProvider = MisskeyChannelTimelineNotifierFamily._();

final class MisskeyChannelTimelineNotifierProvider
    extends $AsyncNotifierProvider<MisskeyChannelTimelineNotifier, List<Note>> {
  MisskeyChannelTimelineNotifierProvider._({
    required MisskeyChannelTimelineNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'misskeyChannelTimelineProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$misskeyChannelTimelineNotifierHash();

  @override
  String toString() {
    return r'misskeyChannelTimelineProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MisskeyChannelTimelineNotifier create() => MisskeyChannelTimelineNotifier();

  @override
  bool operator ==(Object other) {
    return other is MisskeyChannelTimelineNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$misskeyChannelTimelineNotifierHash() =>
    r'47dd5fec4143914dddbf5010ea7e0b2bf54e9884';

final class MisskeyChannelTimelineNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MisskeyChannelTimelineNotifier,
          AsyncValue<List<Note>>,
          List<Note>,
          FutureOr<List<Note>>,
          String
        > {
  MisskeyChannelTimelineNotifierFamily._()
    : super(
        retry: null,
        name: r'misskeyChannelTimelineProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MisskeyChannelTimelineNotifierProvider call(String channelId) =>
      MisskeyChannelTimelineNotifierProvider._(argument: channelId, from: this);

  @override
  String toString() => r'misskeyChannelTimelineProvider';
}

abstract class _$MisskeyChannelTimelineNotifier
    extends $AsyncNotifier<List<Note>> {
  late final _$args = ref.$arg as String;
  String get channelId => _$args;

  FutureOr<List<Note>> build(String channelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Note>>, List<Note>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Note>>, List<Note>>,
              AsyncValue<List<Note>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
