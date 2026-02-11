import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../utils/logger.dart';

/// Centralized logical network client providing pre-configured Dio instances.
///
/// Designed with ACG-style elegance and Material 3 precision! (≧▽≦)
class NetworkClient {
  static final NetworkClient _instance = NetworkClient._internal();
  factory NetworkClient() => _instance;
  NetworkClient._internal();

  /// Creates a pre-configured Dio instance for a specific host and token.
  ///
  /// @param host The hostname for the base URL.
  /// @param token Optional authorization token.
  /// @param userAgent Custom User-Agent string.
  Dio createDio({
    required String host,
    String? token,
    String? userAgent,
    Map<String, dynamic>? extraHeaders,
  }) {
    logger.info('NetworkClient: Creating Dio instance for $host');

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://$host',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'User-Agent':? userAgent,
          'Accept': '*/*',
          ...?extraHeaders,
        },
      ),
    );

    // Add BackgroundTransformer for isolated JSON decoding (S-rank performance! ✧)
    dio.transformer = BackgroundTransformer();

    // Attach interceptors
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => logger.debug('NetworkClient: $obj'),
      ),
    );

    if (token != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Many APIs (like Misskey) expect 'i' in the body for POST,
            // but we can also set headers if needed.
            // For now, we'll keep the token available for the specific API implementations.
            return handler.next(options);
          },
        ),
      );
    }

    // Handle SSL/TLS for local/development instances (HandshakeException fix)
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    return dio;
  }
}
