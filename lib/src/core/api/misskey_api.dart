import 'package:dio/dio.dart';
import '../utils/logger.dart';

class MisskeyApi {
  final String host;
  final String token;
  late Dio _dio;

  MisskeyApi({required this.host, required this.token}) {
    logger.info('MisskeyApi: Initializing for host: $host');
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://$host',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'User-Agent': 'CyaniTalk/1.0.0'},
      ),
    );
    logger.info('MisskeyApi: Initialized successfully');
  }

  Future<Map<String, dynamic>> i() async {
    try {
      logger.info('MisskeyApi: Fetching user information');
      final response = await _dio.post('/api/i', data: {'i': token});

      if (response.statusCode == 200) {
        logger.info('MisskeyApi: Successfully fetched user information');
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Failed to fetch Misskey user: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        logger.error('MisskeyApi: Error fetching user information', e);
        throw Exception('Misskey API error: ${e.message}');
      }
      logger.error('MisskeyApi: Unexpected error fetching user information', e);
      rethrow;
    }
  }

  /// Check if a note still exists on the server
  /// Returns true if the note exists, false if it was deleted (404)
  Future<bool> checkNoteExists(String noteId) async {
    try {
      logger.debug('MisskeyApi: Checking if note exists: $noteId');
      final response = await _dio.post(
        '/api/notes/show',
        data: {'i': token, 'noteId': noteId},
      );

      if (response.statusCode == 200) {
        logger.debug('MisskeyApi: Note $noteId exists');
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        logger.debug('MisskeyApi: Note $noteId was deleted (404)');
        return false;
      }
      // For other errors, assume the note still exists to avoid false deletions
      logger.warning('MisskeyApi: Error checking note $noteId: $e');
      return true;
    }
  }

  /// Get drive usage information
  Future<Map<String, dynamic>> getDriveInfo() async {
    try {
      logger.info('MisskeyApi: Fetching drive usage information');
      final response = await _dio.post('/api/drive', data: {'i': token});

      if (response.statusCode == 200) {
        logger.info('MisskeyApi: Successfully fetched drive usage information');
        return Map<String, dynamic>.from(response.data);
      }
      throw Exception('Failed to fetch drive info: ${response.statusCode}');
    } catch (e) {
      logger.error('MisskeyApi: Error fetching drive info', e);
      rethrow;
    }
  }

  Future<List<dynamic>> getTimeline(
    String type, {
    int limit = 20,
    String? untilId,
  }) async {
    final endpoint = switch (type) {
      'Home' => '/api/notes/timeline',
      'Local' => '/api/notes/local-timeline',
      'Social' => '/api/notes/hybrid-timeline',
      'Global' => '/api/notes/global-timeline',
      _ => '/api/notes/timeline',
    };

    try {
      logger.info(
        'MisskeyApi: Fetching $type timeline, limit=$limit, untilId=$untilId',
      );
      final response = await _dio.post(
        endpoint,
        data: {
          'i': token,
          'limit': limit,
          if (untilId != null) 'untilId': untilId,
        },
      );

      if (response.statusCode == 200) {
        final notes = response.data as List<dynamic>;
        logger.info(
          'MisskeyApi: Successfully fetched ${notes.length} notes for $type timeline',
        );
        return notes;
      }
      throw Exception('Failed to fetch timeline: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        logger.error('MisskeyApi: Error fetching $type timeline', e);
        throw Exception('Misskey API error: ${e.message}');
      }
      logger.error('MisskeyApi: Unexpected error fetching $type timeline', e);
      rethrow;
    }
  }

  Future<List<dynamic>> getChannels({int limit = 20}) async {
    try {
      logger.info('MisskeyApi: Fetching joined channels, limit=$limit');
      final response = await _dio.post(
        '/api/channels/joined',
        data: {'i': token, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final channels = response.data as List<dynamic>;
        logger.info(
          'MisskeyApi: Successfully fetched ${channels.length} joined channels',
        );
        return channels;
      }
      throw Exception('Failed to fetch channels: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        logger.error('MisskeyApi: Error fetching channels', e);
        throw Exception('Misskey API error: ${e.message}');
      }
      logger.error('MisskeyApi: Unexpected error fetching channels', e);
      rethrow;
    }
  }

  Future<List<dynamic>> getChannelTimeline(
    String channelId, {
    int limit = 20,
    String? untilId,
  }) async {
    try {
      logger.info(
        'MisskeyApi: Fetching channel timeline for $channelId, limit=$limit, untilId=$untilId',
      );
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
        final notes = response.data as List<dynamic>;
        logger.info(
          'MisskeyApi: Successfully fetched ${notes.length} notes for channel $channelId timeline',
        );
        return notes;
      }
      throw Exception(
        'Failed to fetch channel timeline: ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        logger.error(
          'MisskeyApi: Error fetching channel $channelId timeline',
          e,
        );
        throw Exception('Misskey API error: ${e.message}');
      }
      logger.error(
        'MisskeyApi: Unexpected error fetching channel $channelId timeline',
        e,
      );
      rethrow;
    }
  }

  Future<void> createNote({
    String? text,
    String? replyId,
    String? renoteId,
  }) async {
    try {
      String action = 'Creating note';
      if (replyId != null) action = 'Replying to note $replyId';
      if (renoteId != null) action = 'Renoting note $renoteId';
      logger.info('MisskeyApi: $action');
      await _dio.post(
        '/api/notes/create',
        data: {
          'i': token,
          if (text != null) 'text': text,
          if (replyId != null) 'replyId': replyId,
          if (renoteId != null) 'renoteId': renoteId,
        },
      );
      logger.info('MisskeyApi: Successfully $action');
    } catch (e) {
      if (e is DioException) {
        logger.error('MisskeyApi: Error creating note', e);
        throw Exception('Misskey API error: ${e.message}');
      }
      logger.error('MisskeyApi: Unexpected error creating note', e);
      rethrow;
    }
  }

  Future<void> createReaction(String noteId, String reaction) async {
    try {
      logger.info('MisskeyApi: Adding reaction "$reaction" to note $noteId');
      await _dio.post(
        '/api/notes/reactions/create',
        data: {'i': token, 'noteId': noteId, 'reaction': reaction},
      );
      logger.info(
        'MisskeyApi: Successfully added reaction "$reaction" to note $noteId',
      );
    } catch (e) {
      if (e is DioException) {
        logger.error('MisskeyApi: Error adding reaction to note $noteId', e);
        throw Exception('Misskey API error: ${e.message}');
      }
      logger.error(
        'MisskeyApi: Unexpected error adding reaction to note $noteId',
        e,
      );
      rethrow;
    }
  }

  Future<void> deleteReaction(String noteId) async {
    try {
      logger.info('MisskeyApi: Removing reaction from note $noteId');
      await _dio.post(
        '/api/notes/reactions/delete',
        data: {'i': token, 'noteId': noteId},
      );
      logger.info(
        'MisskeyApi: Successfully removed reaction from note $noteId',
      );
    } catch (e) {
      if (e is DioException) {
        logger.error(
          'MisskeyApi: Error removing reaction from note $noteId',
          e,
        );
        throw Exception('Misskey API error: ${e.message}');
      }
      logger.error(
        'MisskeyApi: Unexpected error removing reaction from note $noteId',
        e,
      );
      rethrow;
    }
  }

  Future<List<dynamic>> getDriveFiles({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) async {
    try {
      logger.info(
        'MisskeyApi: Fetching drive files, folderId=$folderId, limit=$limit',
      );
      final response = await _dio.post(
        '/api/drive/files',
        data: {
          'i': token,
          'limit': limit,
          if (folderId != null) 'folderId': folderId,
          if (untilId != null) 'untilId': untilId,
        },
      );

      if (response.statusCode == 200) {
        final files = response.data as List<dynamic>;
        logger.info(
          'MisskeyApi: Successfully fetched ${files.length} drive files',
        );
        return files;
      }
      throw Exception('Failed to fetch drive files: ${response.statusCode}');
    } catch (e) {
      logger.error('MisskeyApi: Error fetching drive files', e);
      rethrow;
    }
  }

  Future<List<dynamic>> getDriveFolders({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) async {
    try {
      logger.info(
        'MisskeyApi: Fetching drive folders, folderId=$folderId, limit=$limit',
      );
      final response = await _dio.post(
        '/api/drive/folders',
        data: {
          'i': token,
          'limit': limit,
          if (folderId != null) 'folderId': folderId,
          if (untilId != null) 'untilId': untilId,
        },
      );

      if (response.statusCode == 200) {
        final folders = response.data as List<dynamic>;
        logger.info(
          'MisskeyApi: Successfully fetched ${folders.length} drive folders',
        );
        return folders;
      }
      throw Exception('Failed to fetch drive folders: ${response.statusCode}');
    } catch (e) {
      logger.error('MisskeyApi: Error fetching drive folders', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createDriveFolder(
    String name, {
    String? parentId,
  }) async {
    try {
      logger.info(
        'MisskeyApi: Creating drive folder "$name", parentId=$parentId',
      );
      final response = await _dio.post(
        '/api/drive/folders/create',
        data: {
          'i': token,
          'name': name,
          if (parentId != null) 'parentId': parentId,
        },
      );

      if (response.statusCode == 200) {
        logger.info('MisskeyApi: Successfully created drive folder');
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to create drive folder: ${response.statusCode}');
    } catch (e) {
      logger.error('MisskeyApi: Error creating drive folder', e);
      rethrow;
    }
  }

  Future<void> deleteDriveFile(String fileId) async {
    try {
      logger.info('MisskeyApi: Deleting drive file $fileId');
      await _dio.post(
        '/api/drive/files/delete',
        data: {'i': token, 'fileId': fileId},
      );
      logger.info('MisskeyApi: Successfully deleted drive file');
    } catch (e) {
      logger.error('MisskeyApi: Error deleting drive file', e);
      rethrow;
    }
  }

  Future<void> deleteDriveFolder(String folderId) async {
    try {
      logger.info('MisskeyApi: Deleting drive folder $folderId');
      await _dio.post(
        '/api/drive/folders/delete',
        data: {'i': token, 'folderId': folderId},
      );
      logger.info('MisskeyApi: Successfully deleted drive folder');
    } catch (e) {
      logger.error('MisskeyApi: Error deleting drive folder', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadDriveFile(
    List<int> bytes,
    String filename, {
    String? folderId,
  }) async {
    try {
      logger.info(
        'MisskeyApi: Uploading drive file "$filename", folderId=$folderId',
      );
      final formData = FormData.fromMap({
        'i': token,
        if (folderId != null) 'folderId': folderId,
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _dio.post(
        '/api/drive/files/create',
        data: formData,
      );

      if (response.statusCode == 200) {
        logger.info('MisskeyApi: Successfully uploaded drive file');
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to upload drive file: ${response.statusCode}');
    } catch (e) {
      logger.error('MisskeyApi: Error uploading drive file', e);
      rethrow;
    }
  }
}
