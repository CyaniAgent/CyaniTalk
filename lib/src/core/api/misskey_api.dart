import 'package:dio/dio.dart';

class MisskeyApi {
  final String host;
  final String token;
  late Dio _dio;

  MisskeyApi({required this.host, required this.token}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://$host',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'User-Agent': 'CyaniTalk/1.0.0',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> i() async {
    try {
      final response = await _dio.post(
        '/api/i',
        data: {'i': token},
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Failed to fetch Misskey user: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Misskey API error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getTimeline(String type, {int limit = 20, String? untilId}) async {
    final endpoint = switch (type) {
      'Home' => '/api/notes/timeline',
      'Local' => '/api/notes/local-timeline',
      'Social' => '/api/notes/hybrid-timeline',
      'Global' => '/api/notes/global-timeline',
      _ => '/api/notes/timeline',
    };

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          'i': token,
          'limit': limit,
          if (untilId != null) 'untilId': untilId,
        },
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      throw Exception('Failed to fetch timeline: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Misskey API error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getChannels({int limit = 20}) async {
    try {
      final response = await _dio.post(
        '/api/channels/joined',
        data: {
          'i': token,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      throw Exception('Failed to fetch channels: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Misskey API error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getChannelTimeline(String channelId, {int limit = 20, String? untilId}) async {
    try {
      final response = await _dio.post(
        '/api/channels/timeline',
        data: {
          'i': token,
          'channelId': channelId,
          'limit': limit,
          if (untilId != null) 'untilId': untilId,
        },
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      throw Exception('Failed to fetch channel timeline: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Misskey API error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> createNote({String? text, String? replyId, String? renoteId}) async {
    try {
      await _dio.post(
        '/api/notes/create',
        data: {
          'i': token,
          if (text != null) 'text': text,
          if (replyId != null) 'replyId': replyId,
          if (renoteId != null) 'renoteId': renoteId,
        },
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Misskey API error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> createReaction(String noteId, String reaction) async {
    try {
      await _dio.post(
        '/api/notes/reactions/create',
        data: {
          'i': token,
          'noteId': noteId,
          'reaction': reaction,
        },
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Misskey API error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> deleteReaction(String noteId) async {
    try {
      await _dio.post(
        '/api/notes/reactions/delete',
        data: {
          'i': token,
          'noteId': noteId,
        },
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception('Misskey API error: ${e.message}');
      }
      rethrow;
    }
  }
}
