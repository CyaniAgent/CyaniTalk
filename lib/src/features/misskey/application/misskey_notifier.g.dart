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
    r'80ef4e3db5bc91310141b8d72e6a744cc19774ab';

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
final misskeyChannelsProvider = MisskeyChannelsNotifierFamily._();

final class MisskeyChannelsNotifierProvider
    extends $AsyncNotifierProvider<MisskeyChannelsNotifier, List<Channel>> {
  MisskeyChannelsNotifierProvider._({
    required MisskeyChannelsNotifierFamily super.from,
    required ({MisskeyChannelListType type, String? query}) super.argument,
  }) : super(
         retry: null,
         name: r'misskeyChannelsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$misskeyChannelsNotifierHash();

  @override
  String toString() {
    return r'misskeyChannelsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MisskeyChannelsNotifier create() => MisskeyChannelsNotifier();

  @override
  bool operator ==(Object other) {
    return other is MisskeyChannelsNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$misskeyChannelsNotifierHash() =>
    r'a621181dd4a8b596fd73cb32d907e06c02737906';

final class MisskeyChannelsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MisskeyChannelsNotifier,
          AsyncValue<List<Channel>>,
          List<Channel>,
          FutureOr<List<Channel>>,
          ({MisskeyChannelListType type, String? query})
        > {
  MisskeyChannelsNotifierFamily._()
    : super(
        retry: null,
        name: r'misskeyChannelsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MisskeyChannelsNotifierProvider call({
    MisskeyChannelListType type = MisskeyChannelListType.featured,
    String? query,
  }) => MisskeyChannelsNotifierProvider._(
    argument: (type: type, query: query),
    from: this,
  );

  @override
  String toString() => r'misskeyChannelsProvider';
}

abstract class _$MisskeyChannelsNotifier extends $AsyncNotifier<List<Channel>> {
  late final _$args =
      ref.$arg as ({MisskeyChannelListType type, String? query});
  MisskeyChannelListType get type => _$args.type;
  String? get query => _$args.query;

  FutureOr<List<Channel>> build({
    MisskeyChannelListType type = MisskeyChannelListType.featured,
    String? query,
  });
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
    element.handleCreate(
      ref,
      () => build(type: _$args.type, query: _$args.query),
    );
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
    r'002dbe5a1d600d0bc8a425db533d3cd4d930b4db';

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

@ProviderFor(MisskeyClipsNotifier)
final misskeyClipsProvider = MisskeyClipsNotifierProvider._();

final class MisskeyClipsNotifierProvider
    extends $AsyncNotifierProvider<MisskeyClipsNotifier, List<Clip>> {
  MisskeyClipsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyClipsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyClipsNotifierHash();

  @$internal
  @override
  MisskeyClipsNotifier create() => MisskeyClipsNotifier();
}

String _$misskeyClipsNotifierHash() =>
    r'99fe50cc700591f0f064a7f4afdf9f7e29218af0';

abstract class _$MisskeyClipsNotifier extends $AsyncNotifier<List<Clip>> {
  FutureOr<List<Clip>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Clip>>, List<Clip>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Clip>>, List<Clip>>,
              AsyncValue<List<Clip>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MisskeyOnlineUsersNotifier)
final misskeyOnlineUsersProvider = MisskeyOnlineUsersNotifierProvider._();

final class MisskeyOnlineUsersNotifierProvider
    extends $AsyncNotifierProvider<MisskeyOnlineUsersNotifier, int> {
  MisskeyOnlineUsersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyOnlineUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyOnlineUsersNotifierHash();

  @$internal
  @override
  MisskeyOnlineUsersNotifier create() => MisskeyOnlineUsersNotifier();
}

String _$misskeyOnlineUsersNotifierHash() =>
    r'f847694a24b3e7f0a993118f6285b03a4bb2b100';

abstract class _$MisskeyOnlineUsersNotifier extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MisskeyMeNotifier)
final misskeyMeProvider = MisskeyMeNotifierProvider._();

final class MisskeyMeNotifierProvider
    extends $AsyncNotifierProvider<MisskeyMeNotifier, MisskeyUser> {
  MisskeyMeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyMeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyMeNotifierHash();

  @$internal
  @override
  MisskeyMeNotifier create() => MisskeyMeNotifier();
}

String _$misskeyMeNotifierHash() => r'd5aef511157075b2d3f6355ff395e643630d0157';

abstract class _$MisskeyMeNotifier extends $AsyncNotifier<MisskeyUser> {
  FutureOr<MisskeyUser> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MisskeyUser>, MisskeyUser>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MisskeyUser>, MisskeyUser>,
              AsyncValue<MisskeyUser>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
