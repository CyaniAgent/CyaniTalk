import 'dart:io';

/// Custom [HttpOverrides] to handle SSL certificate verification.
///
/// This is particularly useful for decentralized social media where some
/// instances might have misconfigured or self-signed certificates.
class CyaniHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
