import 'package:dio/dio.dart';
import 'base_api.dart';
import 'network_client.dart';

class JuheAuthApi extends BaseApi {
  final String apiurl;
  final String appid;
  final String appkey;
  final String callback;
  late final Dio _dio;

  JuheAuthApi({
    required this.appid,
    required this.appkey,
    this.apiurl = 'https://juheauth.imikufans.cn/',
    this.callback = 'http://127.0.0.1/SDK/connect.php',
  }) {
    final uri = Uri.parse(apiurl);
    _dio = NetworkClient().createDio(host: uri.host);
  }

  /// 获取登录跳转url
  Future<Map<String, dynamic>> getLoginUrl(String type, String state) async {
    return executeApiCall(
      'JuheAuthApi.getLoginUrl',
      () => _dio.get(
        'api.php',
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
        'api.php',
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
        'api.php',
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
