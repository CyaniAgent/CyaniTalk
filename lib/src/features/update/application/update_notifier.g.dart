// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Update)
final updateProvider = UpdateProvider._();

final class UpdateProvider extends $NotifierProvider<Update, UpdateStateData> {
  UpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateHash();

  @$internal
  @override
  Update create() => Update();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateStateData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateStateData>(value),
    );
  }
}

String _$updateHash() => r'7020e37d70d09a261d66805f00977a45db68d1ee';

abstract class _$Update extends $Notifier<UpdateStateData> {
  UpdateStateData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UpdateStateData, UpdateStateData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdateStateData, UpdateStateData>,
              UpdateStateData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
