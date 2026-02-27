import 'package:dio/dio.dart';
import '/src/core/utils/logger.dart';
import '/src/core/api/base_api.dart';
import '/src/core/api/network_client.dart';
import '/src/core/config/constants.dart';

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
      userAgent: Constants.getUserAgent(),
    );
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

  /// 检查笔记是否仍然存在于服务器上
  ///
  /// 通过调用 `/api/notes/show` 接口检查指定 ID 的笔记是否存在。
  /// 如果笔记不存在（404 错误），返回 false；如果存在，返回 true。
  /// 对于其他错误，默认假设笔记仍然存在，以避免误删除。
  ///
  /// @param noteId 要检查的笔记 ID
  /// @return 如果笔记存在返回 true，不存在返回 false
  Future<bool> checkNoteExists(String noteId) async {
    if (noteId.isEmpty) return false;
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
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          logger.debug('MisskeyApi: Note $noteId was deleted (404)');
          return false;
        } else if (e.response?.statusCode == 400) {
          final errorMessage = e.response?.data?['error']?['message'] ?? '';
          if (errorMessage.contains('No such note')) {
            logger.debug(
              'MisskeyApi: Note $noteId was deleted (400: No such note)',
            );
            return false;
          }
        }
      }
      // For other errors, assume the note still exists to avoid false deletions
      logger.warning('MisskeyApi: Error checking note $noteId: $e');
      return true;
    }
  }

  /// 根据 ID 获取单个笔记
  ///
  /// 通过调用 `/api/notes/show` 接口获取指定 ID 的笔记详情。
  ///
  /// @param noteId 要获取的笔记 ID
  /// @return 笔记详情的 Map 对象
  /// @throws Exception 如果请求失败
  Future<Map<String, dynamic>> getNote(String noteId) async {
    if (noteId.isEmpty) throw Exception('noteId cannot be empty');
    logger.debug('MisskeyApi: Getting note: $noteId');
    try {
      final response = await _dio.post(
        '/api/notes/show',
        data: {'i': token, 'noteId': noteId},
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      logger.error('MisskeyApi: Error getting note: $noteId', e);
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final errorMessage =
              e.response?.data?['error']?['message'] ??
              'Invalid note ID or parameters';
          if (errorMessage.contains('No such note')) {
            throw Exception('Note not found');
          }
          throw Exception('Bad request: $errorMessage');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Note not found');
        }
      }
      throw Exception('Failed to get note: ${e.toString()}');
    }
  }

  /// 获取云盘使用信息
  ///
  /// 通过调用 `/api/drive` 接口获取当前用户的云盘使用情况，
  /// 包括总空间、已用空间等信息。
  ///
  /// @return 云盘使用信息的 Map 对象
  /// @throws DioException 如果请求失败
  Future<Map<String, dynamic>> getDriveInfo() => executeApiCall(
    'MisskeyApi.getDriveInfo',
    () => _dio.post('/api/drive', data: {'i': token}),
    (response) => Map<String, dynamic>.from(response.data),
  );

  /// 从 API 获取列表数据的辅助方法
  ///
  /// 用于统一处理从 API 获取列表类型数据的请求，
  /// 自动添加认证令牌并将响应数据转换为列表格式。
  ///
  /// @param operationName 操作名称，用于日志记录
  /// @param endpoint API 端点路径
  /// @param data 请求数据
  /// @return API 返回的列表数据
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> _fetchList(
    String operationName,
    String endpoint,
    Map<String, dynamic> data,
  ) => executeApiCall(
    operationName,
    () => _dio.post(endpoint, data: {'i': token, ...data}),
    (response) => response.data as List<dynamic>,
    params: data,
    dioErrorParser: (error) =>
        error.response?.data?['error']?['message'] ?? error.message,
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
      'untilId': ?untilId,
    });
  }

  /// 获取推荐频道
  ///
  /// 通过调用 `/api/channels/featured` 接口获取平台推荐的频道列表。
  ///
  /// @return 推荐频道列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getFeaturedChannels() => _fetchList(
    'MisskeyApi.getFeaturedChannels',
    '/api/channels/featured',
    {},
  );

  /// 获取已关注的频道
  ///
  /// 通过调用 `/api/channels/followed` 接口获取当前用户已关注的频道列表。
  ///
  /// @param limit 返回的频道数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 已关注的频道列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getFollowingChannels({
    int limit = 20,
    String? untilId,
  }) => _fetchList(
    'MisskeyApi.getFollowingChannels',
    '/api/channels/followed',
    {'limit': limit, 'untilId': ?untilId},
  );

  /// 获取自己创建的频道
  ///
  /// 通过调用 `/api/channels/owned` 接口获取当前用户创建的频道列表。
  ///
  /// @param limit 返回的频道数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 自己创建的频道列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getOwnedChannels({int limit = 20, String? untilId}) =>
      _fetchList('MisskeyApi.getOwnedChannels', '/api/channels/owned', {
        'limit': limit,
        'untilId': ?untilId,
      });

  /// 获取收藏的频道
  ///
  /// 通过调用 `/api/channels/my-favorites` 接口获取当前用户收藏的频道列表。
  ///
  /// @param limit 返回的频道数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 收藏的频道列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getFavoriteChannels({
    int limit = 20,
    String? untilId,
  }) => _fetchList(
    'MisskeyApi.getFavoriteChannels',
    '/api/channels/my-favorites',
    {'limit': limit, 'untilId': ?untilId},
  );

  /// 搜索频道
  ///
  /// 通过调用 `/api/channels/search` 接口根据关键词搜索频道。
  ///
  /// @param query 搜索关键词
  /// @param limit 返回的频道数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 搜索结果频道列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> searchChannels(
    String query, {
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.searchChannels', '/api/channels/search', {
    'query': query,
    'limit': limit,
    'untilId': ?untilId,
  });

  /// 获取频道详情
  ///
  /// 通过调用 `/api/channels/show` 接口获取指定 ID 的频道详细信息。
  ///
  /// @param channelId 要获取的频道 ID
  /// @return 频道详情的 Map 对象
  /// @throws DioException 如果请求失败
  Future<Map<String, dynamic>> showChannel(String channelId) => executeApiCall(
    'MisskeyApi.showChannel',
    () => _dio.post(
      '/api/channels/show',
      data: {'i': token, 'channelId': channelId},
    ),
    (response) => Map<String, dynamic>.from(response.data),
    params: {'channelId': channelId},
  );

  /// 获取频道时间线
  ///
  /// 通过调用 `/api/channels/timeline` 接口获取指定频道的时间线内容。
  ///
  /// @param channelId 频道 ID
  /// @param limit 返回的笔记数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 频道时间线笔记列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getChannelTimeline(
    String channelId, {
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.getChannelTimeline', '/api/channels/timeline', {
    'channelId': channelId,
    'limit': limit,
    'untilId': ?untilId,
  });

  /// 获取收藏夹列表
  ///
  /// 通过调用 `/api/clips/list` 接口获取当前用户的收藏夹列表。
  ///
  /// @param limit 返回的收藏夹数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 收藏夹列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getClips({int limit = 20, String? untilId}) =>
      _fetchList('MisskeyApi.getClips', '/api/clips/list', {
        'limit': limit,
        'untilId': ?untilId,
      });

  /// 获取收藏夹中的笔记
  ///
  /// 通过调用 `/api/clips/notes` 接口获取指定收藏夹中的笔记列表。
  ///
  /// @param clipId 收藏夹 ID
  /// @param limit 返回的笔记数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 收藏夹中的笔记列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getClipNotes({
    required String clipId,
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.getClipNotes', '/api/clips/notes', {
    'clipId': clipId,
    'limit': limit,
    'untilId': ?untilId,
  });

  /// 创建新笔记
  ///
  /// 通过调用 `/api/notes/create` 接口创建一条新的笔记。
  ///
  /// @param text 笔记内容
  /// @param replyId 回复的笔记 ID
  /// @param renoteId 转发的笔记 ID
  /// @param fileIds 附件文件 ID 列表
  /// @param visibility 可见性：public、home、followers、specified
  /// @param localOnly 是否仅本地可见
  /// @param cw 内容警告
  /// @throws DioException 如果请求失败
  Future<void> createNote({
    String? text,
    String? replyId,
    String? renoteId,
    String? channelId,
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
        'text': ?text,
        'replyId': ?replyId,
        'renoteId': ?renoteId,
        'channelId': ?channelId,
        if (fileIds != null && fileIds.isNotEmpty) 'fileIds': fileIds,
        'visibility': ?visibility,
        'localOnly': ?localOnly,
        'cw': ?cw,
      },
    ),
    params: {
      'text': text,
      'replyId': replyId,
      'renoteId': renoteId,
      'channelId': channelId,
      'fileIds': fileIds,
      'visibility': visibility,
      'localOnly': localOnly,
      'cw': cw,
    },
  );

  /// 创建反应
  ///
  /// 通过调用 `/api/notes/reactions/create` 接口为指定笔记添加反应。
  ///
  /// @param noteId 笔记 ID
  /// @param reaction 反应表情
  /// @throws DioException 如果请求失败
  Future<void> createReaction(String noteId, String reaction) =>
      executeApiCallVoid(
        'MisskeyApi.createReaction',
        () => _dio.post(
          '/api/notes/reactions/create',
          data: {'i': token, 'noteId': noteId, 'reaction': reaction},
        ),
        params: {'noteId': noteId, 'reaction': reaction},
      );

  /// 删除反应
  ///
  /// 通过调用 `/api/notes/reactions/delete` 接口删除对指定笔记的反应。
  ///
  /// @param noteId 笔记 ID
  /// @throws DioException 如果请求失败
  Future<void> deleteReaction(String noteId) => executeApiCallVoid(
    'MisskeyApi.deleteReaction',
    () => _dio.post(
      '/api/notes/reactions/delete',
      data: {'i': token, 'noteId': noteId},
    ),
    params: {'noteId': noteId},
  );

  /// 获取云盘文件列表
  ///
  /// 通过调用 `/api/drive/files` 接口获取云盘中的文件列表。
  ///
  /// @param folderId 文件夹 ID，为空则获取根目录
  /// @param limit 返回的文件数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 云盘文件列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getDriveFiles({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.getDriveFiles', '/api/drive/files', {
    'limit': limit,
    'folderId': ?folderId,
    'untilId': ?untilId,
  });

  /// 获取云盘文件夹列表
  ///
  /// 通过调用 `/api/drive/folders` 接口获取云盘中的文件夹列表。
  ///
  /// @param folderId 父文件夹 ID，为空则获取根目录
  /// @param limit 返回的文件夹数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 云盘文件夹列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getDriveFolders({
    String? folderId,
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.getDriveFolders', '/api/drive/folders', {
    'limit': limit,
    'folderId': ?folderId,
    'untilId': ?untilId,
  });

  /// 创建云盘文件夹
  ///
  /// 通过调用 `/api/drive/folders/create` 接口在云盘中创建新文件夹。
  ///
  /// @param name 文件夹名称
  /// @param parentId 父文件夹 ID，为空则在根目录创建
  /// @return 创建的文件夹信息
  /// @throws DioException 如果请求失败
  Future<Map<String, dynamic>> createDriveFolder(
    String name, {
    String? parentId,
  }) => executeApiCall(
    'MisskeyApi.createDriveFolder',
    () => _dio.post(
      '/api/drive/folders/create',
      data: {'i': token, 'name': name, 'parentId': ?parentId},
    ),
    (response) => response.data as Map<String, dynamic>,
  );

  /// 删除云盘文件
  ///
  /// 通过调用 `/api/drive/files/delete` 接口删除云盘中的文件。
  ///
  /// @param fileId 要删除的文件 ID
  /// @throws DioException 如果请求失败
  Future<void> deleteDriveFile(String fileId) => executeApiCallVoid(
    'MisskeyApi.deleteDriveFile',
    () => _dio.post(
      '/api/drive/files/delete',
      data: {'i': token, 'fileId': fileId},
    ),
    params: {'fileId': fileId},
  );

  /// 删除云盘文件夹
  ///
  /// 通过调用 `/api/drive/folders/delete` 接口删除云盘中的文件夹。
  ///
  /// @param folderId 要删除的文件夹 ID
  /// @throws DioException 如果请求失败
  Future<void> deleteDriveFolder(String folderId) => executeApiCallVoid(
    'MisskeyApi.deleteDriveFolder',
    () => _dio.post(
      '/api/drive/folders/delete',
      data: {'i': token, 'folderId': folderId},
    ),
    params: {'folderId': folderId},
  );

  /// 上传文件到云盘
  ///
  /// 通过调用 `/api/drive/files/create` 接口将文件上传到云盘。
  ///
  /// @param bytes 文件字节数据
  /// @param filename 文件名
  /// @param folderId 目标文件夹 ID，为空则上传到根目录
  /// @return 上传的文件信息
  /// @throws DioException 如果请求失败
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
        'folderId': ?folderId,
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    ),
    (response) => response.data as Map<String, dynamic>,
  );

  /// 获取在线用户数量
  ///
  /// 通过调用 `/api/get-online-users-count` 接口获取当前平台的在线用户数量。
  /// 设置了 30 秒的超时时间，确保在系统资源紧张或网络波动时也能成功。
  ///
  /// @return 在线用户数量
  /// @throws DioException 如果请求失败或超时
  Future<int> getOnlineUsersCount() async {
    try {
      logger.debug('MisskeyApi: Getting online users count');
      final response = await _dio.post(
        '/api/get-online-users-count',
        data: {'i': token},
        options: Options(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      return response.data['count'] as int;
    } catch (e) {
      logger.warning('MisskeyApi: Error getting online users count: $e');
      rethrow;
    }
  }

  // --- Messaging (Chat) API ---

  /// 获取消息历史记录
  ///
  /// 这是一个高度兼容的方法，会尝试多个可能的端点获取消息历史记录。
  /// 首先尝试 `/api/chat/history`，如果失败则尝试 `/api/messaging/history`。
  ///
  /// @param limit 返回的消息数量限制，默认 10
  /// @return 消息历史记录列表
  /// @throws DioException 如果所有端点都请求失败
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

  /// 获取与指定用户的消息
  ///
  /// 这是一个兼容方法，会尝试多个可能的端点获取与指定用户的消息记录。
  /// 首先尝试 `/api/chat/messages/user-timeline`，如果失败则尝试 `/api/messaging/messages`。
  ///
  /// @param userId 用户 ID
  /// @param limit 返回的消息数量限制，默认 10
  /// @param sinceId 分页标记，用于加载更新的消息
  /// @param untilId 分页标记，用于加载更早的消息
  /// @param markAsRead 是否标记为已读，默认 true
  /// @return 消息列表
  /// @throws DioException 如果所有端点都请求失败
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
      'sinceId': ?sinceId,
      'untilId': ?untilId,
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
      params: data,
    );
  }

  /// 向指定用户发送消息
  ///
  /// 这是一个兼容方法，会尝试多个可能的端点向指定用户发送消息。
  /// 首先尝试 `/api/chat/messages/create-to-user`，如果失败则尝试 `/api/messaging/messages/create`。
  ///
  /// @param userId 接收消息的用户 ID
  /// @param text 消息内容
  /// @param fileId 附件文件 ID
  /// @return 创建的消息信息
  /// @throws DioException 如果所有端点都请求失败
  Future<Map<String, dynamic>> createMessagingMessage({
    required String userId,
    String? text,
    String? fileId,
  }) {
    final data = {
      'i': token,
      'userId': userId,
      'text': ?text,
      'fileId': ?fileId,
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
      params: data,
    );
  }

  /// 标记消息为已读
  ///
  /// 通过调用 `/api/messaging/messages/read` 接口标记指定消息为已读。
  /// 注意：新的 Chat API 提供了 'read-all' 接口，需要 userId/roomId 而不是单个 messageId。
  /// 但为了兼容标准 Misskey，保留此方法。
  ///
  /// @param messageId 要标记为已读的消息 ID
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

  /// 删除消息
  ///
  /// 通过调用 `/api/chat/messages/delete` 接口删除指定的消息。
  ///
  /// @param messageId 要删除的消息 ID
  /// @throws DioException 如果请求失败
  Future<void> deleteMessagingMessage(String messageId) => executeApiCallVoid(
    'MisskeyApi.deleteMessagingMessage',
    () => _dio.post(
      '/api/chat/messages/delete',
      data: {'i': token, 'messageId': messageId},
    ),
    params: {'messageId': messageId},
  );

  // --- Chat Room API (New) ---

  /// 创建聊天室
  ///
  /// 通过调用 `/api/chat/rooms/create` 接口创建一个新的聊天室。
  ///
  /// @param name 聊天室名称
  /// @return 创建的聊天室信息
  /// @throws DioException 如果请求失败
  Future<Map<String, dynamic>> createChatRoom(String name) => executeApiCall(
    'MisskeyApi.createChatRoom',
    () => _dio.post('/api/chat/rooms/create', data: {'i': token, 'name': name}),
    (response) => Map<String, dynamic>.from(response.data),
    params: {'name': name},
  );

  /// 获取已加入的聊天室
  ///
  /// 这是一个兼容方法，会尝试多个可能的端点获取已加入的聊天室列表。
  /// 首先尝试 `/api/chat/rooms/joining`，如果失败则尝试 `/api/users/groups/joined`。
  ///
  /// @return 已加入的聊天室列表
  /// @throws DioException 如果所有端点都请求失败
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

  /// 获取聊天室消息
  ///
  /// 通过调用 `/api/chat/messages/room-timeline` 接口获取指定聊天室的消息列表。
  ///
  /// @param roomId 聊天室 ID
  /// @param limit 返回的消息数量限制，默认 20
  /// @return 聊天室消息列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getChatRoomMessages(String roomId, {int limit = 20}) =>
      _fetchList(
        'MisskeyApi.getChatRoomMessages',
        '/api/chat/messages/room-timeline',
        {'roomId': roomId, 'limit': limit},
      );

  /// 发送聊天室消息
  ///
  /// 通过调用 `/api/chat/messages/create-to-room` 接口向指定聊天室发送消息。
  ///
  /// @param roomId 聊天室 ID
  /// @param text 消息内容
  /// @param fileId 附件文件 ID
  /// @throws DioException 如果请求失败
  Future<void> sendChatRoomMessage(
    String roomId, {
    String? text,
    String? fileId,
  }) => executeApiCallVoid(
    'MisskeyApi.sendChatRoomMessage',
    () => _dio.post(
      '/api/chat/messages/create-to-room',
      data: {'i': token, 'roomId': roomId, 'text': ?text, 'fileId': ?fileId},
    ),
    params: {'roomId': roomId, 'text': text, 'fileId': fileId},
  );

  // --- Clips (Bookmarks) ---

  /// 创建收藏夹
  ///
  /// 通过调用 `/api/clips/create` 接口创建一个新的收藏夹。
  ///
  /// @param name 收藏夹名称
  /// @param isPublic 是否公开，默认 false
  /// @param description 收藏夹描述
  /// @return 创建的收藏夹信息
  /// @throws DioException 如果请求失败
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
        'description': ?description,
      },
    ),
    (response) => Map<String, dynamic>.from(response.data),
    params: {'name': name, 'isPublic': isPublic, 'description': description},
  );

  /// 将笔记添加到收藏夹
  ///
  /// 通过调用 `/api/clips/add-note` 接口将指定笔记添加到收藏夹中。
  ///
  /// @param clipId 收藏夹 ID
  /// @param noteId 要添加的笔记 ID
  /// @throws DioException 如果请求失败
  Future<void> addNoteToClip(String clipId, String noteId) =>
      executeApiCallVoid(
        'MisskeyApi.addNoteToClip',
        () => _dio.post(
          '/api/clips/add-note',
          data: {'i': token, 'clipId': clipId, 'noteId': noteId},
        ),
        params: {'clipId': clipId, 'noteId': noteId},
      );

  // --- Reporting ---

  /// 获取用户信息
  ///
  /// 通过调用 `/api/users/show` 接口获取指定用户的详细信息。
  ///
  /// @param userId 用户 ID
  /// @return 用户信息的 Map 对象
  /// @throws DioException 如果请求失败
  Future<Map<String, dynamic>> showUser(String userId) => executeApiCall(
    'MisskeyApi.showUser',
    () => _dio.post('/api/users/show', data: {'i': token, 'userId': userId}),
    (response) => Map<String, dynamic>.from(response.data),
    params: {'userId': userId},
  );

  /// 举报用户
  ///
  /// 通过调用 `/api/users/report-abuse` 接口举报指定用户。
  ///
  /// @param userId 要举报的用户 ID
  /// @param comment 举报理由
  /// @throws DioException 如果请求失败
  Future<void> reportUser(String userId, String comment) => executeApiCallVoid(
    'MisskeyApi.reportUser',
    () => _dio.post(
      '/api/users/report-abuse',
      data: {'i': token, 'userId': userId, 'comment': comment},
    ),
    params: {'userId': userId, 'comment': comment},
  );

  // --- Notifications ---

  /// 获取通知列表
  ///
  /// 通过调用 `/api/i/notifications` 接口获取当前用户的通知列表。
  ///
  /// @param limit 返回的通知数量限制，默认 20
  /// @param sinceId 分页标记，用于加载更新的通知
  /// @param untilId 分页标记，用于加载更早的通知
  /// @param includeTypes 要包含的通知类型列表
  /// @param excludeTypes 要排除的通知类型列表
  /// @return 通知列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getNotifications({
    int limit = 20,
    String? sinceId,
    String? untilId,
    List<String>? includeTypes,
    List<String>? excludeTypes,
  }) => _fetchList('MisskeyApi.getNotifications', '/api/i/notifications', {
    'limit': limit,
    'sinceId': ?sinceId,
    'untilId': ?untilId,
    'includeTypes': ?includeTypes,
    'excludeTypes': ?excludeTypes,
  });

  /// 搜索笔记
  ///
  /// 通过调用 `/api/notes/search` 接口根据关键词搜索笔记。
  ///
  /// @param query 搜索关键词
  /// @param limit 返回的笔记数量限制，默认 20
  /// @param untilId 分页标记，用于加载更多内容
  /// @return 搜索结果笔记列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> searchNotes(
    String query, {
    int limit = 20,
    String? untilId,
  }) => _fetchList('MisskeyApi.searchNotes', '/api/notes/search', {
    'query': query,
    'limit': limit,
    'untilId': ?untilId,
  });

  /// 获取实例元数据
  ///
  /// 通过调用 `/api/meta` 接口获取实例的元数据信息，包括策略、功能开关等。
  ///
  /// @return 实例元数据的 Map 对象
  Future<Map<String, dynamic>> getMeta() => executeApiCall(
    'MisskeyApi.getMeta',
    () => _dio.post('/api/meta', data: {'i': token}),
    (response) => Map<String, dynamic>.from(response.data),
  );

  /// 搜索用户
  ///
  /// 通过调用 `/api/users/search` 接口根据关键词搜索用户。
  ///
  /// @param query 搜索关键词
  /// @param limit 返回的用户数量限制，默认 20
  /// @param offset 分页偏移量
  /// @return 搜索结果用户列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> searchUsers(
    String query, {
    int limit = 20,
    String? offset,
  }) => _fetchList('MisskeyApi.searchUsers', '/api/users/search', {
    'query': query,
    'limit': limit,
    'offset': ?offset,
  });

  /// 获取单个表情信息
  ///
  /// 通过调用 `/api/emoji` 接口获取指定名称的表情详细信息。
  ///
  /// @param name 表情名称
  /// @return 表情详细信息的 Map 对象
  /// @throws DioException 如果请求失败
  Future<Map<String, dynamic>> getEmoji(String name) => executeApiCall(
    'MisskeyApi.getEmoji',
    () => _dio.post('/api/emoji', data: {'i': token, 'name': name}),
    (response) => Map<String, dynamic>.from(response.data),
    params: {'name': name},
  );

  /// 获取表情列表
  ///
  /// 通过调用 `/api/emojis` 接口获取实例的表情列表。
  ///
  /// @return 表情列表的 Map 对象，包含 emojis 字段
  /// @throws DioException 如果请求失败
  Future<Map<String, dynamic>> getEmojis() => executeApiCall(
    'MisskeyApi.getEmojis',
    () => _dio.post('/api/emojis', data: {'i': token}),
    (response) => Map<String, dynamic>.from(response.data),
  );

  /// 获取当前用户的公告列表
  ///
  /// 通过调用 `/api/announcements` 接口获取当前用户需要查看的公告。
  /// 包括全局公告和未读的公告。
  ///
  /// @param limit 返回的公告数量限制，默认 10
  /// @param withUnreads 是否包含未读公告，默认 true
  /// @param isActive 是否只返回活跃的公告，默认 true
  /// @return 公告列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getAnnouncements({
    int limit = 10,
    bool withUnreads = true,
    bool isActive = true,
  }) => _fetchList('MisskeyApi.getAnnouncements', '/api/announcements', {
    'limit': limit,
    'withUnreads': withUnreads,
    'isActive': isActive,
  });

  /// 标记公告为已读
  ///
  /// 通过调用 `/api/i/read-announcement` 接口标记指定公告为已读。
  ///
  /// @param announcementId 要标记为已读的公告 ID
  /// @throws DioException 如果请求失败
  Future<void> readAnnouncement(String announcementId) => executeApiCall(
    'MisskeyApi.readAnnouncement',
    () => _dio.post(
      '/api/i/read-announcement',
      data: {'i': token, 'announcementId': announcementId},
    ),
    (response) => response.data,
    params: {'announcementId': announcementId},
  );

  /// 获取笔记的反应列表
  ///
  /// 通过调用 `/api/notes/reactions` 接口获取指定笔记的反应列表。
  ///
  /// @param noteId 笔记 ID
  /// @param type 反应类型（可选）
  /// @param limit 返回数量限制，默认 10
  /// @param sinceId 起始 ID（可选）
  /// @param untilId 结束 ID（可选）
  /// @param sinceDate 起始日期时间戳（可选）
  /// @param untilDate 结束日期时间戳（可选）
  /// @return 反应列表
  /// @throws DioException 如果请求失败
  Future<List<dynamic>> getNoteReactions(
    String noteId, {
    String? type,
    int limit = 10,
    String? sinceId,
    String? untilId,
    int? sinceDate,
    int? untilDate,
  }) => _fetchList('MisskeyApi.getNoteReactions', '/api/notes/reactions', {
    'noteId': noteId,
    'limit': limit,
    'type': type,
    'sinceId': sinceId,
    'untilId': untilId,
    'sinceDate': sinceDate,
    'untilDate': untilDate,
  });
}
