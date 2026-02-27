// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misskey_announcements_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MisskeyAnnouncementsNotifier)
final misskeyAnnouncementsProvider = MisskeyAnnouncementsNotifierProvider._();

final class MisskeyAnnouncementsNotifierProvider
    extends
        $AsyncNotifierProvider<
          MisskeyAnnouncementsNotifier,
          List<Announcement>
        > {
  MisskeyAnnouncementsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyAnnouncementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyAnnouncementsNotifierHash();

  @$internal
  @override
  MisskeyAnnouncementsNotifier create() => MisskeyAnnouncementsNotifier();
}

String _$misskeyAnnouncementsNotifierHash() =>
    r'ae5b62f1401dbc22c6fdacc0587f4ec6055583f2';

abstract class _$MisskeyAnnouncementsNotifier
    extends $AsyncNotifier<List<Announcement>> {
  FutureOr<List<Announcement>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Announcement>>, List<Announcement>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Announcement>>, List<Announcement>>,
              AsyncValue<List<Announcement>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
