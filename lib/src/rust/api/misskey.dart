class MisskeyRustClient {
  final String host;
  final String token;

  MisskeyRustClient({required this.host, required this.token});

  Future<String> i() async => "{}";
  
  Future<String> getTimeline({
    required String timelineType,
    required int limit,
    String? untilId,
  }) async => "[]";

  Future<String> createNote({
    String? text,
    String? replyId,
    String? renoteId,
    String? visibility,
  }) async => "{}";

  Future<void> createReaction({
    required String noteId,
    required String reaction,
  }) async {}
}
