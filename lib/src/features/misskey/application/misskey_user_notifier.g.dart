// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_user_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MisskeyUserNotifier)
final misskeyUserProvider = MisskeyUserNotifierFamily._();

final class MisskeyUserNotifierProvider
    extends $AsyncNotifierProvider<MisskeyUserNotifier, MisskeyUser> {
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
    r'c1dc66fb676c5dff709d9f780a7110f96d5f9559';

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

  MisskeyUserNotifierProvider call(String userId) =>
      MisskeyUserNotifierProvider._(argument: userId, from: this);

  @override
  String toString() => r'misskeyUserProvider';
}

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
