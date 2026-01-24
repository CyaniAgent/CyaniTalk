import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/flarum_constants.dart';
import '../utils/verification_window.dart';
import '../../routing/router.dart';

class FlarumApi {
  static final FlarumApi _instance = FlarumApi._internal();

  factory FlarumApi() => _instance;

  FlarumApi._internal() {
    _initDio();
  }

  late Dio _dio;
  late CookieJar _cookieJar;
  String? _token;
  String? _baseUrl = 'https://flarum.imikufans.cn';

  String _getEndpointKey(String endpoint, String key) {
    final endpointHash = endpoint.hashCode.toString();
    return '${FlarumConstants.endpointDataPrefix}$endpointHash$key';
  }

  void _initDio() {
    debugPrint('FlarumApi: Initializing Dio with baseUrl: $_baseUrl');

    final basicHeaders = {
      'Accept': 'application/vnd.api+json',
      'Content-Type': 'application/vnd.api+json',
    };

    String userAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    if (Platform.isAndroid) {
      userAgent =
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      userAgent =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
    }

    final browserHeaders = {
      'User-Agent': userAgent,
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Referer': _baseUrl!,
      'Origin': _baseUrl!,
    };

    final headers = {...basicHeaders, ...browserHeaders};

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl!,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: headers,
      ),
    );

    _dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 10),
        onClientCreate: (uri, config) {},
      ),
    );

    _cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint('FlarumApi: Request - ${options.method} ${options.uri}');
          if (_token != null) {
            options.headers['Authorization'] = 'Token $_token';
          }

          final prefs = await SharedPreferences.getInstance();
          final uaType =
              prefs.getString(FlarumConstants.userAgentTypeKey) ??
              FlarumConstants.defaultUserAgentType;

          String userAgent;
          if (uaType == FlarumConstants.userAgentTypeChrome) {
            userAgent = Platform.isAndroid
                ? 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.76 Mobile Safari/537.36'
                : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7559.60 Safari/537.36';
          } else if (uaType == FlarumConstants.userAgentTypeFirefox) {
            userAgent =
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0';
          } else {
            userAgent =
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
            if (Platform.isAndroid) {
              userAgent =
                  'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
            } else if (Platform.isIOS) {
              userAgent =
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
            }
          }

          options.headers['User-Agent'] = userAgent;
          options.headers['Referer'] = _baseUrl;
          options.headers['Origin'] = _baseUrl;

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'FlarumApi: Response - ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          final statusCode = e.response?.statusCode;
          final isWafError = statusCode == 403 ||
              statusCode == 405 ||
              statusCode == 400 ||
              statusCode == 429 ||
              statusCode == 503;

          if (isWafError) {
            debugPrint('FlarumApi: WAF or related error detected ($statusCode)');
            final requestOptions = e.requestOptions;
            final url = '${requestOptions.baseUrl}${requestOptions.path}';

            try {
              final context = rootNavigatorKey.currentContext;
              if (context != null) {
                final cookieValue = await VerificationWindow.show(context, url);

                if (cookieValue != null) {
                  debugPrint('FlarumApi: WAF verification success, cookie retrieved');

                  final uri = Uri.parse(_baseUrl!);
                  final cookie = Cookie('acw_sc__v2', cookieValue)
                    ..domain = uri.host
                    ..path = '/'
                    ..httpOnly = true;

                  await _cookieJar.saveFromResponse(uri, [cookie]);

                  debugPrint('FlarumApi: Retrying request...');
                  final response = await _dio.fetch(requestOptions);
                  return handler.resolve(response);
                } else {
                  debugPrint('FlarumApi: WAF verification cancelled');
                }
              }
            } catch (err) {
              debugPrint('FlarumApi: WAF verification failed: $err');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
    _dio.options.headers['Referer'] = url;
    _dio.options.headers['Origin'] = url;
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  String? get token => _token;
  String? get baseUrl => _baseUrl;

  Future<void> saveEndpoint(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final endpoints = await getEndpoints();

    if (!endpoints.contains(url)) {
      endpoints.add(url);
      await prefs.setStringList(FlarumConstants.endpointsKey, endpoints);
    }

    await prefs.setString(FlarumConstants.currentEndpointKey, url);
    setBaseUrl(url);
  }

  Future<void> loadEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    final currentEndpoint = prefs.getString(FlarumConstants.currentEndpointKey);
    if (currentEndpoint != null) {
      setBaseUrl(currentEndpoint);
      await loadToken(currentEndpoint);
    } else {
      setBaseUrl(_baseUrl!);
    }
  }

  Future<List<String>> getEndpoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(FlarumConstants.endpointsKey) ?? [];
  }

  Future<void> switchEndpoint(String url) async {
    final prefs = await SharedPreferences.getInstance();

    if (_baseUrl != null && _token != null) {
      await saveToken(_baseUrl!, _token!);
    }

    await prefs.setString(FlarumConstants.currentEndpointKey, url);
    setBaseUrl(url);
    await loadToken(url);
  }

  Future<void> deleteEndpoint(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final endpoints = await getEndpoints();

    endpoints.remove(url);
    await prefs.setStringList(FlarumConstants.endpointsKey, endpoints);

    final currentEndpoint = prefs.getString(FlarumConstants.currentEndpointKey);
    if (currentEndpoint == url) {
      if (endpoints.isNotEmpty) {
        await switchEndpoint(endpoints.first);
      } else {
        await prefs.remove(FlarumConstants.currentEndpointKey);
        setBaseUrl(_baseUrl!);
        clearToken();
      }
    }
    await clearEndpointData(url);
  }

  Future<void> saveToken(String endpoint, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenKey = _getEndpointKey(endpoint, FlarumConstants.tokenKey);
    await prefs.setString(tokenKey, token);
  }

  Future<void> loadToken(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenKey = _getEndpointKey(endpoint, FlarumConstants.tokenKey);
    final token = prefs.getString(tokenKey);
    _token = token;
  }

  Future<void> clearTokenForEndpoint(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenKey = _getEndpointKey(endpoint, FlarumConstants.tokenKey);
    await prefs.remove(tokenKey);
    if (_baseUrl == endpoint) {
      clearToken();
    }
  }

  Future<void> clearEndpointData(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) {
      final endpointHash = endpoint.hashCode.toString();
      return key.startsWith('${FlarumConstants.endpointDataPrefix}$endpointHash');
    }).toList();

    for (final key in keys) {
      await prefs.remove(key);
    }

    if (_baseUrl == endpoint) {
      clearToken();
    }
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _cookieJar.deleteAll();
    clearToken();
    setBaseUrl('https://flarum.imikufans.cn');
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
