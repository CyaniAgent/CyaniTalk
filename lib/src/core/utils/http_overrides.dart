import 'dart:io';

/// 自定义 [HttpOverrides]，用于处理 SSL 证书验证。
///
/// 这在去中心化社交媒体中特别有用，某些实例可能配置了错误或自签名证书。
class CyaniHttpOverrides extends HttpOverrides {
  /// 是否启用 SSL 证书验证
  final bool enableCertificateValidation;

  /// 创建 [CyaniHttpOverrides] 的新实例
  CyaniHttpOverrides({
    this.enableCertificateValidation = true,
  });

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (!enableCertificateValidation) {
          // Always trust certificates if validation is disabled
          return true;
        } else {
          // Use default certificate validation
          return false;
        }
      };
  }
}
