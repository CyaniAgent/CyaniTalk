// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Misskey时间线状态管理类
///
/// 负责管理Misskey平台的各种时间线，包括本地、全球、社交等类型的时间线。
/// 支持实时更新、加载更多和刷新功能。
/// 使用缓存管理器提高性能，支持后台比对和自动更新。

@ProviderFor(MisskeyTimelineNotifier)
final misskeyTimelineProvider = MisskeyTimelineNotifierFamily._();

/// Misskey时间线状态管理类
///
/// 负责管理Misskey平台的各种时间线，包括本地、全球、社交等类型的时间线。
/// 支持实时更新、加载更多和刷新功能。
/// 使用缓存管理器提高性能，支持后台比对和自动更新。
final class MisskeyTimelineNotifierProvider
    extends $AsyncNotifierProvider<MisskeyTimelineNotifier, List<Note>> {
  /// Misskey时间线状态管理类
  ///
  /// 负责管理Misskey平台的各种时间线，包括本地、全球、社交等类型的时间线。
  /// 支持实时更新、加载更多和刷新功能。
  /// 使用缓存管理器提高性能，支持后台比对和自动更新。
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
    r'40bf2a8b66b6a48cd08f69ff37a1d5cd1ff05787';

/// Misskey时间线状态管理类
///
/// 负责管理Misskey平台的各种时间线，包括本地、全球、社交等类型的时间线。
/// 支持实时更新、加载更多和刷新功能。
/// 使用缓存管理器提高性能，支持后台比对和自动更新。

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

  /// Misskey时间线状态管理类
  ///
  /// 负责管理Misskey平台的各种时间线，包括本地、全球、社交等类型的时间线。
  /// 支持实时更新、加载更多和刷新功能。
  /// 使用缓存管理器提高性能，支持后台比对和自动更新。

  MisskeyTimelineNotifierProvider call(String type) =>
      MisskeyTimelineNotifierProvider._(argument: type, from: this);

  @override
  String toString() => r'misskeyTimelineProvider';
}

/// Misskey时间线状态管理类
///
/// 负责管理Misskey平台的各种时间线，包括本地、全球、社交等类型的时间线。
/// 支持实时更新、加载更多和刷新功能。
/// 使用缓存管理器提高性能，支持后台比对和自动更新。

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

/// Misskey频道列表状态管理类

@ProviderFor(MisskeyChannelsNotifier)
final misskeyChannelsProvider = MisskeyChannelsNotifierFamily._();

/// Misskey频道列表状态管理类
final class MisskeyChannelsNotifierProvider
    extends $AsyncNotifierProvider<MisskeyChannelsNotifier, List<Channel>> {
  /// Misskey频道列表状态管理类
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
    r'5607081063d555078f8613faab9899ff41aa88d3';

/// Misskey频道列表状态管理类

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

  /// Misskey频道列表状态管理类

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

/// Misskey频道列表状态管理类

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

/// Misskey频道时间线状态管理类

@ProviderFor(MisskeyChannelTimelineNotifier)
final misskeyChannelTimelineProvider = MisskeyChannelTimelineNotifierFamily._();

/// Misskey频道时间线状态管理类
final class MisskeyChannelTimelineNotifierProvider
    extends $AsyncNotifierProvider<MisskeyChannelTimelineNotifier, List<Note>> {
  /// Misskey频道时间线状态管理类
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
    r'77f31fffe9149745c41307b9a28a141e7865f019';

/// Misskey频道时间线状态管理类

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

  /// Misskey频道时间线状态管理类

  MisskeyChannelTimelineNotifierProvider call(String channelId) =>
      MisskeyChannelTimelineNotifierProvider._(argument: channelId, from: this);

  @override
  String toString() => r'misskeyChannelTimelineProvider';
}

/// Misskey频道时间线状态管理类

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

/// Misskey片段(Clips)列表状态管理类

@ProviderFor(MisskeyClipsNotifier)
final misskeyClipsProvider = MisskeyClipsNotifierProvider._();

/// Misskey片段(Clips)列表状态管理类
final class MisskeyClipsNotifierProvider
    extends $AsyncNotifierProvider<MisskeyClipsNotifier, List<Clip>> {
  /// Misskey片段(Clips)列表状态管理类
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
    r'dc73fd1c49bde7a859065e7f41258bb3ce84221a';

/// Misskey片段(Clips)列表状态管理类

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

/// Misskey片段笔记状态管理类

@ProviderFor(MisskeyClipNotesNotifier)
final misskeyClipNotesProvider = MisskeyClipNotesNotifierFamily._();

/// Misskey片段笔记状态管理类
final class MisskeyClipNotesNotifierProvider
    extends $AsyncNotifierProvider<MisskeyClipNotesNotifier, List<Note>> {
  /// Misskey片段笔记状态管理类
  MisskeyClipNotesNotifierProvider._({
    required MisskeyClipNotesNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'misskeyClipNotesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$misskeyClipNotesNotifierHash();

  @override
  String toString() {
    return r'misskeyClipNotesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MisskeyClipNotesNotifier create() => MisskeyClipNotesNotifier();

  @override
  bool operator ==(Object other) {
    return other is MisskeyClipNotesNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$misskeyClipNotesNotifierHash() =>
    r'9712ec6bff11d9c4bfd6557a615a10e9af1f2133';

/// Misskey片段笔记状态管理类

final class MisskeyClipNotesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MisskeyClipNotesNotifier,
          AsyncValue<List<Note>>,
          List<Note>,
          FutureOr<List<Note>>,
          String
        > {
  MisskeyClipNotesNotifierFamily._()
    : super(
        retry: null,
        name: r'misskeyClipNotesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Misskey片段笔记状态管理类

  MisskeyClipNotesNotifierProvider call(String clipId) =>
      MisskeyClipNotesNotifierProvider._(argument: clipId, from: this);

  @override
  String toString() => r'misskeyClipNotesProvider';
}

/// Misskey片段笔记状态管理类

abstract class _$MisskeyClipNotesNotifier extends $AsyncNotifier<List<Note>> {
  late final _$args = ref.$arg as String;
  String get clipId => _$args;

  FutureOr<List<Note>> build(String clipId);
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

/// Misskey在线用户数状态管理类

@ProviderFor(MisskeyOnlineUsersNotifier)
final misskeyOnlineUsersProvider = MisskeyOnlineUsersNotifierProvider._();

/// Misskey在线用户数状态管理类
final class MisskeyOnlineUsersNotifierProvider
    extends $AsyncNotifierProvider<MisskeyOnlineUsersNotifier, int> {
  /// Misskey在线用户数状态管理类
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
    r'edfefc91f45880b74e9fcd18b7847ebff4877add';

/// Misskey在线用户数状态管理类

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

/// 当前Misskey用户状态管理类

@ProviderFor(MisskeyMeNotifier)
final misskeyMeProvider = MisskeyMeNotifierProvider._();

/// 当前Misskey用户状态管理类
final class MisskeyMeNotifierProvider
    extends $AsyncNotifierProvider<MisskeyMeNotifier, MisskeyUser> {
  /// 当前Misskey用户状态管理类
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

String _$misskeyMeNotifierHash() => r'feb6fe1eec4e9910bdcbcc8f10e038be36725b9b';

/// 当前Misskey用户状态管理类

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

/// Misskey用户信息状态管理类

@ProviderFor(MisskeyUserNotifier)
final misskeyUserProvider = MisskeyUserNotifierFamily._();

/// Misskey用户信息状态管理类
final class MisskeyUserNotifierProvider
    extends $AsyncNotifierProvider<MisskeyUserNotifier, MisskeyUser> {
  /// Misskey用户信息状态管理类
  MisskeyUserNotifierProvider._({
    required MisskeyUserNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'misskeyUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$misskeyUserNotifierHash();

  @override
  String toString() {
    return r'misskeyUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MisskeyUserNotifier create() => MisskeyUserNotifier();

  @override
  bool operator ==(Object other) {
    return other is MisskeyUserNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$misskeyUserNotifierHash() =>
    r'2a54c34578416b32291bc6120b0395d0422249b3';

/// Misskey用户信息状态管理类

final class MisskeyUserNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MisskeyUserNotifier,
          AsyncValue<MisskeyUser>,
          MisskeyUser,
          FutureOr<MisskeyUser>,
          String
        > {
  MisskeyUserNotifierFamily._()
    : super(
        retry: null,
        name: r'misskeyUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Misskey用户信息状态管理类

  MisskeyUserNotifierProvider call(String userId) =>
      MisskeyUserNotifierProvider._(argument: userId, from: this);

  @override
  String toString() => r'misskeyUserProvider';
}

/// Misskey用户信息状态管理类

abstract class _$MisskeyUserNotifier extends $AsyncNotifier<MisskeyUser> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<MisskeyUser> build(String userId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}
