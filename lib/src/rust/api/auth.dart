class JuheAuthClient {
  final String appid;
  final String appkey;
  final String apiurl;
  final String callback;

  JuheAuthClient({
    required this.appid,
    required this.appkey,
    required this.apiurl,
    required this.callback,
  });

  Future<String> getLoginUrl({required String type, required String state}) async => "{}";
  Future<String> callbackAuth({required String code}) async => "{}";
  Future<String> queryUser({required String type, required String socialUid}) async => "{}";
}
