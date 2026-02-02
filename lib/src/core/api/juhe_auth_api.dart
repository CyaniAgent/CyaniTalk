import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'base_api.dart';

class JuheAuthApi extends BaseApi {
  final String apiurl;
  final String appid;
  final String appkey;
  final String callback;
  late Dio _dio;

  JuheAuthApi({
    this.apiurl = 'https://u.cccyun.cc/',
    this.appid = '1000',
    this.appkey = '1111111111111111111111111111',
    this.callback = 'http://127.0.0.1/SDK/connect.php',
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiurl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'User-Agent': _generateUserAgent()},
      ),
    );

    // 允许自定义证书校验
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  String _generateUserAgent() {
    if (Platform.isAndroid) {
      return 'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
    } else {
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36';
    }
  }

  /// 获取登录跳转url
  Future<Map<String, dynamic>> getLoginUrl(String type, String state) async {
    return executeApiCall(
      'JuheAuthApi.getLoginUrl',
      () => _dio.get(
        'connect.php',
        queryParameters: {
          'act': 'login',
          'appid': appid,
          'appkey': appkey,
          'type': type,
          'redirect_uri': callback,
          'state': state,
        },
      ),
      (response) => Map<String, dynamic>.from(response.data),
    );
  }

  /// 登录成功回调获取用户信息
  Future<Map<String, dynamic>> callbackAuth(String code) async {
    return executeApiCall(
      'JuheAuthApi.callbackAuth',
      () => _dio.get(
        'connect.php',
        queryParameters: {
          'act': 'callback',
          'appid': appid,
          'appkey': appkey,
          'code': code,
        },
      ),
      (response) => Map<String, dynamic>.from(response.data),
    );
  }

  /// 查询用户信息
  Future<Map<String, dynamic>> queryUser(String type, String socialUid) async {
    return executeApiCall(
      'JuheAuthApi.queryUser',
      () => _dio.get(
        'connect.php',
        queryParameters: {
          'act': 'query',
          'appid': appid,
          'appkey': appkey,
          'type': type,
          'social_uid': socialUid,
        },
      ),
      (response) => Map<String, dynamic>.from(response.data),
    );
  }
}
