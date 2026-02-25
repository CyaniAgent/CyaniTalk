import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/flarum_constants.dart';
import '../utils/verification_window.dart';
import '../utils/utils.dart';
import '../utils/logger.dart';
import '../../routing/router.dart';
import 'base_api.dart';
import 'network_client.dart';

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
  String? _baseUrl; // 移除硬编码默认值

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
      userAgent =
          'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      userAgent =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
    } else {
      userAgent =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36';
    }

    final browserHeaders = {
      'User-Agent': userAgent,
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Referer': _baseUrl ?? '',
      'Origin': _baseUrl ?? '',
    };

    final headers = {...basicHeaders, ...browserHeaders};

    // 如果 _baseUrl 为空，创建一个占位 Dio，防止初始化报错
    _dio = NetworkClient().createDio(
      host: _baseUrl?.replaceFirst('https://', '') ?? 'placeholder.com',
      userAgent: userAgent,
      extraHeaders: headers,
    );

    _cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_baseUrl == null) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Flarum API base URL is not set.',
              ),
            );
          }

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

          if (isWafError && _baseUrl != null) {
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
    _userId = null;
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
      // 如果没有保存的端点，保持 _baseUrl 为空
      _baseUrl = null;
      _dio.options.baseUrl = 'https://placeholder.com';
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
        _baseUrl = null; // 彻底清除
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
    _baseUrl = null;
    clearToken();
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
    if (_baseUrl == null) throw Exception('Flarum site URL is not set.');
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

  /// 获取 Flarum 用户详细资料
  ///
  /// [userId] - 用户 ID
  Future<Map<String, dynamic>> getUserProfile(String userId) => executeApiCall(
    'FlarumApi.getUserProfile',
    () => get('/api/users/$userId'),
    (response) => Map<String, dynamic>.from(response.data),
    params: {'userId': userId},
    dioErrorParser: (error) =>
        error.response?.data?['errors']?[0]?['detail'] ?? error.message,
  );

  /// 获取讨论列表
  Future<Map<String, dynamic>> getDiscussions({
    int? limit,
    int? offset,
    String? include,
  }) => executeApiCall(
    'FlarumApi.getDiscussions',
    () => get(
      '/api/discussions',
      queryParameters: {
        'page[limit]': ?limit,
        'page[offset]': ?offset,
        'include': ?include,
      },
    ),
    (response) => Map<String, dynamic>.from(response.data),
    params: {'limit': limit, 'offset': offset, 'include': include},
  );

  /// 搜索讨论
  Future<Map<String, dynamic>> searchDiscussions(
    String query, {
    int? limit,
    int? offset,
  }) => executeApiCall(
    'FlarumApi.searchDiscussions',
    () => get(
      '/api/discussions',
      queryParameters: {
        'filter[q]': query,
        'page[limit]': ?limit,
        'page[offset]': ?offset,
        'include': 'user,lastPostedUser,tags',
      },
    ),
    (response) => Map<String, dynamic>.from(response.data),
    params: {'query': query, 'limit': limit, 'offset': offset},
  );

  /// 获取讨论详情
  Future<Map<String, dynamic>> getDiscussionDetails(String id) =>
      executeApiCall(
        'FlarumApi.getDiscussionDetails',
        () => get(
          '/api/discussions/$id',
          queryParameters: {
            'include': 'user,posts,posts.user,posts.discussion,tags',
          },
        ),
        (response) => Map<String, dynamic>.from(response.data),
        params: {'id': id},
      );

  /// 获取帖子列表
  Future<Map<String, dynamic>> getPosts(
    String discussionId, {
    int? limit,
    int? offset,
  }) => executeApiCall(
    'FlarumApi.getPosts',
    () => get(
      '/api/posts',
      queryParameters: {
        'filter[discussion]': discussionId,
        'filter[type]': 'comment',
        'page[limit]': ?limit,
        'page[offset]': ?offset,
        'include': 'user,discussion',
      },
    ),
    (response) => Map<String, dynamic>.from(response.data),
    params: {'discussionId': discussionId, 'limit': limit, 'offset': offset},
  );

  /// 获取所有标签
  Future<Map<String, dynamic>> getTags() => executeApiCall(
    'FlarumApi.getTags',
    () => get('/api/tags'),
    (response) => Map<String, dynamic>.from(response.data),
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
