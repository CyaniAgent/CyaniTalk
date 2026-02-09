import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/logger.dart';
import 'base_api.dart';
import 'network_client.dart';
import '../config/constants.dart';

/// Misskey API客户端
///
/// 提供与Misskey实例交互的API方法，包括获取时间线、用户信息、文件管理等功能。
///
/// @param host Misskey实例的主机名
/// @param token 认证令牌
class MisskeyApi extends BaseApi {
  final String host;
  final String token;
  late Dio _dio;

  /// 初始化Misskey API客户端
  ///
  /// @param host Misskey实例的主机名
  /// @param token 认证令牌
  MisskeyApi({required this.host, required this.token}) {
    logger.info('MisskeyApi: Initializing for host: $host');

    _dio = NetworkClient().createDio(
      host: host,
      token: token,
      userAgent: _generateUserAgent(),
    );
  }

  /// 生成更加真实的User-Agent字符串
  String _generateUserAgent() {
    if (Platform.isAndroid) {
      return 'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36 CyaniTalk/${Constants.appVersion}';
    } else if (Platform.isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1 CyaniTalk/${Constants.appVersion}';
    } else {
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 CyaniTalk/${Constants.appVersion}';
    }
  }

  /// 获取当前用户信息
  ///
  /// 返回当前认证用户的详细信息，包括用户名、头像、个人简介等。
  ///
  /// @return 用户信息的Map对象
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

  /// Get a single note by ID
  Future<Map<String, dynamic>> getNote(String noteId) async {
    logger.debug('MisskeyApi: Getting note: $noteId');
    return executeApiCall(
      'MisskeyApi.getNote',
      () => _dio.post('/api/notes/show', data: {'i': token, 'noteId': noteId}),
      (response) => Map<String, dynamic>.from(response.data),
    );
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

  /// 获取时间线
  ///
  /// 根据指定的类型获取不同的时间线内容，支持Home、Local、Social和Global四种类型。
  ///
  /// @param type 时间线类型：Home(主页)、Local(本地)、Social(社交)、Global(全球)
  /// @param limit 返回的笔记数量限制，默认20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 笔记列表
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

    return _fetchList('MisskeyApi.getTimeline', endpoint, {
      'limit': limit,
      if (untilId != null) 'untilId': untilId,
    });
  }

  Future<List<dynamic>> getFeaturedChannels() => _fetchList(
    'MisskeyApi.getFeaturedChannels',
    '/api/channels/featured',
    {},
  );

  Future<List<dynamic>> getFollowingChannels({
    int limit = 20,
    String? untilId,
  }) => _fetchList(
    'MisskeyApi.getFollowingChannels',
    '/api/channels/followed',
    {'limit': limit, if (untilId != null) 'untilId': untilId},
  );

  Future<List<dynamic>> getOwnedChannels({int limit = 20, String? untilId}) =>
      _fetchList('MisskeyApi.getOwnedChannels', '/api/channels/owned', {
        'limit': limit,
        if (untilId != null) 'untilId': untilId,
      });

  Future<List<dynamic>> getFavoriteChannels({
    int limit = 20,
    String? untilId,
  }) => _fetchList(
    'MisskeyApi.getFavoriteChannels',
    '/api/channels/my-favorites',
    {'limit': limit, if (untilId != null) 'untilId': untilId},
  );

  Future<List<dynamic>> searchChannels(
    String query, {
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.searchChannels', '/api/channels/search', {
    'query': query,
    'limit': limit,
    if (untilId != null) 'untilId': untilId,
  });

  Future<Map<String, dynamic>> showChannel(String channelId) => executeApiCall(
    'MisskeyApi.showChannel',
    () => _dio.post(
      '/api/channels/show',
      data: {'i': token, 'channelId': channelId},
    ),
    (response) => Map<String, dynamic>.from(response.data),
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

  Future<List<dynamic>> getClipNotes({
    required String clipId,
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.getClipNotes', '/api/clips/notes', {
    'clipId': clipId,
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

  Future<int> getOnlineUsersCount() async {
    try {
      logger.debug('MisskeyApi: Getting online users count');
      final response = await _dio.post(
        '/api/get-online-users-count',
        data: {'i': token},
        options: Options(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.data['count'] as int;
    } catch (e) {
      logger.warning('MisskeyApi: Error getting online users count: $e');
      rethrow;
    }
  }

  // --- Messaging (Chat) API ---

  /// 这是一个高度兼容的方法，会尝试多个可能的端点
  Future<List<dynamic>> getMessagingHistory({int limit = 10}) =>
      executeApiCall('MisskeyApi.getMessagingHistory', () async {
        try {
          return await _dio.post(
            '/api/chat/history',
            data: {'i': token, 'limit': limit},
          );
        } catch (e) {
          return await _dio.post(
            '/api/messaging/history',
            data: {'i': token, 'limit': limit},
          );
        }
      }, (response) => response.data as List<dynamic>);

  Future<List<dynamic>> getMessagingMessages({
    required String userId,
    int limit = 10,
    String? sinceId,
    String? untilId,
    bool markAsRead = true,
  }) {
    final data = {
      'i': token,
      'userId': userId,
      'limit': limit,
      if (sinceId != null) 'sinceId': sinceId,
      if (untilId != null) 'untilId': untilId,
      'markAsRead': markAsRead,
    };

    return executeApiCall(
      'MisskeyApi.getMessagingMessages',
      () async {
        try {
          return await _dio.post(
            '/api/chat/messages/user-timeline',
            data: data,
          );
        } catch (e) {
          return await _dio.post('/api/messaging/messages', data: data);
        }
      },
      (response) => response.data as List<dynamic>,
    );
  }

  Future<Map<String, dynamic>> createMessagingMessage({
    required String userId,
    String? text,
    String? fileId,
  }) {
    final data = {
      'i': token,
      'userId': userId,
      if (text != null) 'text': text,
      if (fileId != null) 'fileId': fileId,
    };

    return executeApiCall(
      'MisskeyApi.createMessagingMessage',
      () async {
        try {
          return await _dio.post(
            '/api/chat/messages/create-to-user',
            data: data,
          );
        } catch (e) {
          return await _dio.post('/api/messaging/messages/create', data: data);
        }
      },
      (response) => Map<String, dynamic>.from(response.data),
    );
  }

  Future<void> readMessagingMessage(String messageId) async {
    // Note: The new Chat API provides 'read-all' which takes a userId/roomId, not a single messageId.
    // However, keeping this for compatibility with standard Misskey.
    // For Chat API, we might need a different method to mark conversation as read.
    // For now, we try 'read-all' with the messageId as a fallback if the API is confusing,
    // but likely 'read-all' expects 'userId'.
    // Since we don't have userId here, we'll skip the chat endpoint for single message read
    // OR we could change this method signature.
    // Given the constraints, let's keep the standard messaging fallback.

    final data = {'i': token, 'messageId': messageId};
    try {
      // Standard Misskey
      await _dio.post('/api/messaging/messages/read', data: data);
    } catch (e) {
      logger.warning(
        'MisskeyApi: /api/messaging/messages/read failed. Chat API may require read-all per user.',
      );
    }
  }

  Future<void> deleteMessagingMessage(String messageId) => executeApiCallVoid(
    'MisskeyApi.deleteMessagingMessage',
    () => _dio.post(
      '/api/chat/messages/delete',
      data: {'i': token, 'messageId': messageId},
    ),
  );

  // --- Chat Room API (New) ---

  Future<Map<String, dynamic>> createChatRoom(String name) => executeApiCall(
    'MisskeyApi.createChatRoom',
    () => _dio.post('/api/chat/rooms/create', data: {'i': token, 'name': name}),
    (response) => Map<String, dynamic>.from(response.data),
  );

  Future<List<dynamic>> getChatRooms() => executeApiCall(
    'MisskeyApi.getChatRooms',
    () async {
      try {
        return await _dio.post('/api/chat/rooms/joining', data: {'i': token});
      } catch (e) {
        return await _dio.post('/api/users/groups/joined', data: {'i': token});
      }
    },
    (response) => response.data as List<dynamic>,
  );

  Future<List<dynamic>> getChatRoomMessages(String roomId, {int limit = 20}) =>
      _fetchList(
        'MisskeyApi.getChatRoomMessages',
        '/api/chat/messages/room-timeline',
        {'roomId': roomId, 'limit': limit},
      );

  Future<void> sendChatRoomMessage(
    String roomId, {
    String? text,
    String? fileId,
  }) => executeApiCallVoid(
    'MisskeyApi.sendChatRoomMessage',
    () => _dio.post(
      '/api/chat/messages/create-to-room',
      data: {
        'i': token,
        'roomId': roomId,
        if (text != null) 'text': text,
        if (fileId != null) 'fileId': fileId,
      },
    ),
  );

  // --- Clips (Bookmarks) ---

  Future<Map<String, dynamic>> createClip(
    String name, {
    bool isPublic = false,
    String? description,
  }) => executeApiCall(
    'MisskeyApi.createClip',
    () => _dio.post(
      '/api/clips/create',
      data: {
        'i': token,
        'name': name,
        'isPublic': isPublic,
        if (description != null) 'description': description,
      },
    ),
    (response) => Map<String, dynamic>.from(response.data),
  );

  Future<void> addNoteToClip(String clipId, String noteId) =>
      executeApiCallVoid(
        'MisskeyApi.addNoteToClip',
        () => _dio.post(
          '/api/clips/add-note',
          data: {'i': token, 'clipId': clipId, 'noteId': noteId},
        ),
      );

  // --- Reporting ---

  Future<Map<String, dynamic>> showUser(String userId) => executeApiCall(
    'MisskeyApi.showUser',
    () => _dio.post('/api/users/show', data: {'i': token, 'userId': userId}),
    (response) => Map<String, dynamic>.from(response.data),
  );

  Future<void> reportUser(String userId, String comment) => executeApiCallVoid(
    'MisskeyApi.reportUser',
    () => _dio.post(
      '/api/users/report-abuse',
      data: {'i': token, 'userId': userId, 'comment': comment},
    ),
  );

  // --- Notifications ---

  Future<List<dynamic>> getNotifications({
    int limit = 20,
    String? sinceId,
    String? untilId,
    List<String>? includeTypes,
    List<String>? excludeTypes,
  }) => _fetchList('MisskeyApi.getNotifications', '/api/i/notifications', {
    'limit': limit,
    if (sinceId != null) 'sinceId': sinceId,
    if (untilId != null) 'untilId': untilId,
    if (includeTypes != null) 'includeTypes': includeTypes,
    if (excludeTypes != null) 'excludeTypes': excludeTypes,
  });

  /// 搜索笔记
  Future<List<dynamic>> searchNotes(
    String query, {
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.searchNotes', '/api/notes/search', {
    'query': query,
    'limit': limit,
    if (untilId != null) 'untilId': untilId,
  });

  /// 搜索用户
  Future<List<dynamic>> searchUsers(
    String query, {
    int limit = 20,
    String? offset,
  }) => _fetchList('MisskeyApi.searchUsers', '/api/users/search', {
    'query': query,
    'limit': limit,
    if (offset != null) 'offset': offset,
  });
}
