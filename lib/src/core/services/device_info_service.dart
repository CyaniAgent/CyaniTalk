import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_info_service.g.dart';

class XiaomiDeviceInfo {
  final bool isXiaomi;
  final bool isMiuiOrHyperOS;
  final String brand;
  final String systemInfo;

  const XiaomiDeviceInfo({
    required this.isXiaomi,
    required this.isMiuiOrHyperOS,
    required this.brand,
    required this.systemInfo,
  });

  bool get isXiaomiWithMiSystem => isXiaomi && isMiuiOrHyperOS;
}

@Riverpod(keepAlive: true)
Future<XiaomiDeviceInfo> xiaomiDeviceInfo(Ref ref) async {
  if (!Platform.isAndroid) {
    return const XiaomiDeviceInfo(
      isXiaomi: false,
      isMiuiOrHyperOS: false,
      brand: '',
      systemInfo: '',
    );
  }

  try {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final brand = androidInfo.brand;
    final manufacturer = androidInfo.manufacturer;
    final fingerprint = androidInfo.fingerprint;
    final display = androidInfo.display;
    final hardware = androidInfo.hardware;
    final product = androidInfo.product;

    final brandLower = brand.toLowerCase();
    final manufacturerLower = manufacturer.toLowerCase();
    final combinedLower = '$fingerprint $display $hardware $product'.toLowerCase();

    final isXiaomi = brandLower.contains('xiaomi') ||
        brandLower.contains('redmi') ||
        brandLower.contains('poco') ||
        brandLower.contains('mi') ||
        manufacturerLower.contains('xiaomi');

    final isMiuiOrHyperOS = combinedLower.contains('miui') ||
        combinedLower.contains('hyper') ||
        combinedLower.contains('xiaomi');

    final systemDisplayName = isMiuiOrHyperOS
        ? (combinedLower.contains('hyper') ? 'HyperOS' : 'MIUI')
        : androidInfo.version.release;

    return XiaomiDeviceInfo(
      isXiaomi: isXiaomi,
      isMiuiOrHyperOS: isMiuiOrHyperOS,
      brand: brand,
      systemInfo: systemDisplayName,
    );
  } catch (_) {
    return const XiaomiDeviceInfo(
      isXiaomi: false,
      isMiuiOrHyperOS: false,
      brand: '',
      systemInfo: '',
    );
  }
}