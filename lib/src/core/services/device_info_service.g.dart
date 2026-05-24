// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(xiaomiDeviceInfo)
final xiaomiDeviceInfoProvider = XiaomiDeviceInfoProvider._();

final class XiaomiDeviceInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<XiaomiDeviceInfo>,
          XiaomiDeviceInfo,
          FutureOr<XiaomiDeviceInfo>
        >
    with $FutureModifier<XiaomiDeviceInfo>, $FutureProvider<XiaomiDeviceInfo> {
  XiaomiDeviceInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xiaomiDeviceInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xiaomiDeviceInfoHash();

  @$internal
  @override
  $FutureProviderElement<XiaomiDeviceInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<XiaomiDeviceInfo> create(Ref ref) {
    return xiaomiDeviceInfo(ref);
  }
}

String _$xiaomiDeviceInfoHash() => r'b0c6f204e1b5c428ed03efaa122df3608d2a35cb';
