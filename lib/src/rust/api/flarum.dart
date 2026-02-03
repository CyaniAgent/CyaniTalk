class FlarumRustClient {
  final String baseUrl;

  FlarumRustClient({required this.baseUrl});

  Future<void> setToken({required String token, String? userId}) async {}
  Future<void> clearToken() async {}
  
  Future<String> get({required String path}) async => "{}";
  Future<String> post({required String path, required String bodyJson}) async => "{}";
}
