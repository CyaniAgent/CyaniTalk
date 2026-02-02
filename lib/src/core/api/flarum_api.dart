import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/flarum_constants.dart';
import '../utils/verification_window.dart';
import '../utils/utils.dart';
import '../../routing/router.dart';
import 'base_api.dart';

class FlarumApi extends BaseApi {
  static final FlarumApi _instance = FlarumApi._internal();

  factory FlarumApi() => _instance;

  FlarumApi._internal() {
    _initDio();
  }

  late Dio _dio;
  late CookieJar _cookieJar;
  String? _token;
  String? _userId;
  String? _baseUrl = 'https://flarum.imikufans.cn';

  String _getEndpointKey(String endpoint, String key) {
    final endpointHash = endpoint.hashCode.toString();
    return '${FlarumConstants.endpointDataPrefix}$endpointHash$key';
  }

  void _initDio() {
    logger.info('FlarumApi: 初始化Dio，基础URL: $_baseUrl');

    final basicHeaders = {
      'Accept': 'application/vnd.api+json',
      'Content-Type': 'application/vnd.api+json',
    };

    String userAgent;
    if (Platform.isAndroid) {
      userAgent = 'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      userAgent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
    } else {
      userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36';
    }

    final browserHeaders = {
      'User-Agent': userAgent,
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Referer': _baseUrl ?? '',
      'Origin': _baseUrl ?? '',
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
          logger.debug('FlarumApi: 请求 - ${options.method} ${options.uri}');
          if (_token != null) {
            String header = 'Token $_token';
            if (_userId != null) {
              header += '; userId=$_userId';
            }
            options.headers['Authorization'] = header;
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
          logger.debug(
            'FlarumApi: 响应 - ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          final statusCode = e.response?.statusCode;
          final isWafError =
              statusCode == 403 ||
              statusCode == 405 ||
              statusCode == 400 ||
              statusCode == 429 ||
              statusCode == 503;

          if (isWafError) {
            logger.warning('FlarumApi: 检测到WAF或相关错误 ($statusCode)');
            final requestOptions = e.requestOptions;
            final url = '${requestOptions.baseUrl}${requestOptions.path}';

            try {
              final context = rootNavigatorKey.currentContext;
              if (context != null) {
                final cookieValue = await VerificationWindow.show(context, url);

                if (cookieValue != null) {
                  logger.info('FlarumApi: WAF验证成功，获取到Cookie');

                  final uri = Uri.parse(_baseUrl!);
                  final cookie = Cookie('acw_sc__v2', cookieValue)
                    ..domain = uri.host
                    ..path = '/'
                    ..httpOnly = true;

                  await _cookieJar.saveFromResponse(uri, [cookie]);

                  logger.debug('FlarumApi: 重试请求...');
                  final response = await _dio.fetch(requestOptions);
                  return handler.resolve(response);
                } else {
                  logger.info('FlarumApi: WAF验证被取消');
                }
              }
            } catch (err) {
              logger.error('FlarumApi: WAF验证失败: $err');
            }
          } else {
            logger.error('FlarumApi: 请求错误: ${e.message}, 状态码: $statusCode');
          }
          return handler.next(e);
        },
      ),
    );
  }

  void setBaseUrl(String url) {
    logger.info('FlarumApi: 设置基础URL: $url');
    _baseUrl = url;
    _dio.options.baseUrl = url;
    _dio.options.headers['Referer'] = url;
    _dio.options.headers['Origin'] = url;
  }

  void setToken(String token, {String? userId}) {
    logger.debug('FlarumApi: 设置令牌');
    _token = token;
    _userId = userId;
  }

  void clearToken() {
    logger.debug('FlarumApi: 清除令牌');
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
      return key.startsWith(
        '${FlarumConstants.endpointDataPrefix}$endpointHash',
      );
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

  /// 使用用户名/邮箱和密码登录 Flarum
  ///
  /// [identification] - 用户名或邮箱
  /// [password] - 密码
  ///
  /// 成功时返回包含 token 和 userId 的 Map
  Future<Map<String, dynamic>> login(
    String identification,
    String password,
  ) async {
    logger.info('FlarumApi: 开始登录，用户: $identification');
    try {
      final response = await post(
        '/api/token',
        data: {'identification': identification, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data.containsKey('token')) {
          final token = data['token'];
          final userId = data['userId']?.toString();
          logger.info('FlarumApi: 登录成功');
          setToken(token, userId: userId);
          return Map<String, dynamic>.from(data);
        }
      }
      logger.error('FlarumApi: 登录失败，状态码: ${response.statusCode}');
      throw Exception('Login failed: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data?['errors']?[0]?['detail'] ?? e.message;
        logger.error('FlarumApi: 登录错误: $msg');
        throw Exception('Flarum login error: $msg');
      }
      logger.error('FlarumApi: 登录异常: $e');
      rethrow;
    }
  }

  /// 使用聚合登录（WeChat/QQ）登录 Flarum
  ///
  /// [socialUid] - 聚合登录返回的 social_uid
  /// [type] - 登录类型 (qq, wx 等)
  Future<Map<String, dynamic>> loginWithJuhe(
    String socialUid,
    String type,
  ) async {
    logger.info('FlarumApi: 开始聚合登录，类型: $type, UID: $socialUid');
    try {
      // 注意：这里的路径是假设的，实际路径取决于 Flarum 插件的实现
      // 常见的路径可能是 /api/auth/juhe 或 /api/juhe/login
      final response = await post(
        '/api/juhe/login',
        data: {'social_uid': socialUid, 'type': type},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data.containsKey('token')) {
          final token = data['token'];
          final userId = data['userId']?.toString();
          logger.info('FlarumApi: 聚合登录成功');
          setToken(token, userId: userId);
          return Map<String, dynamic>.from(data);
        }
      }
      logger.error('FlarumApi: 聚合登录失败，状态码: ${response.statusCode}');
      throw Exception('Juhe login failed: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data?['errors']?[0]?['detail'] ?? e.message;
        logger.error('FlarumApi: 聚合登录错误: $msg');
        throw Exception('Flarum Juhe login error: $msg');
      }
      logger.error('FlarumApi: 聚合登录异常: $e');
      rethrow;
    }
  }

  /// 获取 Flarum 用户详细资料
  ///
  /// [userId] - 用户 ID
  Future<Map<String, dynamic>> getUserProfile(String userId) => executeApiCall(
    'FlarumApi.getUserProfile',
    () => get('/api/users/$userId'),
    (response) => Map<String, dynamic>.from(response.data),
    dioErrorParser: (error) =>
        error.response?.data?['errors']?[0]?['detail'] ?? error.message,
  );

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
