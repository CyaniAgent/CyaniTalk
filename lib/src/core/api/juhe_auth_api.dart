import 'dart:convert';
import 'package:cyanitalk/src/rust/api/auth.dart';
import '../utils/logger.dart';
import 'base_api.dart';

class JuheAuthApi extends BaseApi {
  final String apiurl;
  final String appid;
  final String appkey;
  final String callback;
  late JuheAuthClient _rustClient;

  JuheAuthApi({
    required this.appid,
    required this.appkey,
    this.apiurl = 'https://u.cccyun.cc/',
    this.callback = 'http://127.0.0.1/SDK/connect.php',
  }) {
    _rustClient = JuheAuthClient(
      appid: appid,
      appkey: appkey,
      apiurl: apiurl,
      callback: callback,
    );
  }

  /// 获取登录跳转url
  Future<Map<String, dynamic>> getLoginUrl(String type, String state) async {
    try {
      logger.info('JuheAuthApi.getLoginUrl: Starting');
      final jsonString = await _rustClient.getLoginUrl(type: type, state: state);
      final data = jsonDecode(jsonString);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      logger.error('JuheAuthApi.getLoginUrl: Error', e);
      throw Exception('JuheAuthApi.getLoginUrl error: $e');
    }
  }

  /// 登录成功回调获取用户信息
  Future<Map<String, dynamic>> callbackAuth(String code) async {
    try {
      logger.info('JuheAuthApi.callbackAuth: Starting');
      final jsonString = await _rustClient.callbackAuth(code: code);
      final data = jsonDecode(jsonString);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      logger.error('JuheAuthApi.callbackAuth: Error', e);
      throw Exception('JuheAuthApi.callbackAuth error: $e');
    }
  }

  /// 查询用户信息
  Future<Map<String, dynamic>> queryUser(String type, String socialUid) async {
    try {
      logger.info('JuheAuthApi.queryUser: Starting');
      final jsonString = await _rustClient.queryUser(type: type, socialUid: socialUid);
      final data = jsonDecode(jsonString);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      logger.error('JuheAuthApi.queryUser: Error', e);
      throw Exception('JuheAuthApi.queryUser error: $e');
    }
  }
}
