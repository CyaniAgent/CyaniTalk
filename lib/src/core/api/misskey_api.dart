import 'package:dio/dio.dart';
import '../utils/logger.dart';
import 'base_api.dart';
import '../config/constants.dart';

class MisskeyApi extends BaseApi {
  final String host;
  final String token;
  late Dio _dio;

  MisskeyApi({required this.host, required this.token}) {
    logger.info('MisskeyApi: Initializing for host: $host');
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://$host',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'User-Agent':
              'CyaniTalk/${Constants.appVersion} (Android; Mobile; rv:1.0)',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> i() => executeApiCall(
    'MisskeyApi.i',
    () => _dio.post('/api/i', data: {'i': token}),
    (response) => Map<String, dynamic>.from(response.data),
  );

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
  Future<Map<String, dynamic>> getDriveInfo() => executeApiCall(
    'MisskeyApi.getDriveInfo',
    () => _dio.post('/api/drive', data: {'i': token}),
    (response) => Map<String, dynamic>.from(response.data),
  );

  /// Helper method for fetching lists of items from the API
  Future<List<dynamic>> _fetchList(
    String operationName,
    String endpoint,
    Map<String, dynamic> data,
  ) => executeApiCall(
    operationName,
    () => _dio.post(endpoint, data: {'i': token, ...data}),
    (response) => response.data as List<dynamic>,
  );

  Future<List<dynamic>> getTimeline(
    String type, {
    int limit = 20,
    String? untilId,
  }) {
    final endpoint = switch (type) {
      'Home' => '/api/notes/timeline',
      'Local' => '/api/notes/local-timeline',
      'Social' => '/api/notes/hybrid-timeline',
      'Global' => '/api/notes/global-timeline',
      _ => '/api/notes/timeline',
    };

    return _fetchList('MisskeyApi.getTimeline[$type]', endpoint, {
      'limit': limit,
      if (untilId != null) 'untilId': untilId,
    });
  }

  Future<List<dynamic>> getChannels({int limit = 20}) => _fetchList(
    'MisskeyApi.getChannels',
    '/api/channels/joined',
    {'limit': limit},
  );

  Future<List<dynamic>> getChannelTimeline(
    String channelId, {
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.getChannelTimeline', '/api/channels/timeline', {
    'channelId': channelId,
    'limit': limit,
    if (untilId != null) 'untilId': untilId,
  });

  Future<List<dynamic>> getClips({int limit = 20, String? untilId}) =>
      _fetchList('MisskeyApi.getClips', '/api/clips/list', {
        'limit': limit,
        if (untilId != null) 'untilId': untilId,
      });

  Future<void> createNote({
    String? text,
    String? replyId,
    String? renoteId,
    List<String>? fileIds,
    String? visibility,
    bool? localOnly,
    String? cw,
  }) => executeApiCallVoid(
    'MisskeyApi.createNote',
    () => _dio.post(
      '/api/notes/create',
      data: {
        'i': token,
        if (text != null) 'text': text,
        if (replyId != null) 'replyId': replyId,
        if (renoteId != null) 'renoteId': renoteId,
        if (fileIds != null && fileIds.isNotEmpty) 'fileIds': fileIds,
        if (visibility != null) 'visibility': visibility,
        if (localOnly != null) 'localOnly': localOnly,
        if (cw != null) 'cw': cw,
      },
    ),
  );

  Future<void> createReaction(String noteId, String reaction) =>
      executeApiCallVoid(
        'MisskeyApi.createReaction',
        () => _dio.post(
          '/api/notes/reactions/create',
          data: {'i': token, 'noteId': noteId, 'reaction': reaction},
        ),
      );

  Future<void> deleteReaction(String noteId) => executeApiCallVoid(
    'MisskeyApi.deleteReaction',
    () => _dio.post(
      '/api/notes/reactions/delete',
      data: {'i': token, 'noteId': noteId},
    ),
  );

  Future<List<dynamic>> getDriveFiles({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.getDriveFiles', '/api/drive/files', {
    'limit': limit,
    if (folderId != null) 'folderId': folderId,
    if (untilId != null) 'untilId': untilId,
  });

  Future<List<dynamic>> getDriveFolders({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.getDriveFolders', '/api/drive/folders', {
    'limit': limit,
    if (folderId != null) 'folderId': folderId,
    if (untilId != null) 'untilId': untilId,
  });

  Future<Map<String, dynamic>> createDriveFolder(
    String name, {
    String? parentId,
  }) => executeApiCall(
    'MisskeyApi.createDriveFolder',
    () => _dio.post(
      '/api/drive/folders/create',
      data: {
        'i': token,
        'name': name,
        if (parentId != null) 'parentId': parentId,
      },
    ),
    (response) => response.data as Map<String, dynamic>,
  );

  Future<void> deleteDriveFile(String fileId) => executeApiCallVoid(
    'MisskeyApi.deleteDriveFile',
    () => _dio.post(
      '/api/drive/files/delete',
      data: {'i': token, 'fileId': fileId},
    ),
  );

  Future<void> deleteDriveFolder(String folderId) => executeApiCallVoid(
    'MisskeyApi.deleteDriveFolder',
    () => _dio.post(
      '/api/drive/folders/delete',
      data: {'i': token, 'folderId': folderId},
    ),
  );

  Future<Map<String, dynamic>> uploadDriveFile(
    List<int> bytes,
    String filename, {
    String? folderId,
  }) => executeApiCall(
    'MisskeyApi.uploadDriveFile',
    () => _dio.post(
      '/api/drive/files/create',
      data: FormData.fromMap({
        'i': token,
        if (folderId != null) 'folderId': folderId,
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    ),
    (response) => response.data as Map<String, dynamic>,
  );

  Future<int> getOnlineUsersCount() => executeApiCall(
    'MisskeyApi.getOnlineUsersCount',
    () => _dio.post('/api/get-online-users-count', data: {'i': token}),
    (response) => response.data['count'] as int,
  );
}
