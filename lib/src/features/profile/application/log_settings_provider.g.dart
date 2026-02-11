// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LogSettingsNotifier)
final logSettingsProvider = LogSettingsNotifierProvider._();

final class LogSettingsNotifierProvider
    extends $AsyncNotifierProvider<LogSettingsNotifier, LogSettings> {
  LogSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logSettingsNotifierHash();

  @$internal
  @override
  LogSettingsNotifier create() => LogSettingsNotifier();
}

String _$logSettingsNotifierHash() =>
    r'42a9baa798bd096b7a7e65a1fcd2b7356f258a12';

abstract class _$LogSettingsNotifier extends $AsyncNotifier<LogSettings> {
  FutureOr<LogSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LogSettings>, LogSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LogSettings>, LogSettings>,
              AsyncValue<LogSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
