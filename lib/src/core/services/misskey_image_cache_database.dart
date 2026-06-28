import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '/src/core/services/database_path_helper.dart';
import '/src/core/utils/logger.dart';

/// 图片缓存类型枚举
enum ImageCacheType {
  postImage,    // 帖子图片
  avatar,       // 用户头像
  banner,       // 用户横幅
  emoji,        // 表情图片
  thumbnail,    // 缩略图
}

/// 图片缓存记录数据模型
class ImageCacheRecord {
  final String id;
  final String imageUrl;
  final String? localPath;
  final ImageCacheType cacheType;
  final String? associatedUserId;
  final String? associatedNoteId;
  final String? associatedHost;
  final DateTime cachedAt;
  final DateTime lastAccessedAt;
  final int accessCount;
  final int fileSizeBytes;

  const ImageCacheRecord({
    required this.id,
    required this.imageUrl,
    this.localPath,
    required this.cacheType,
    this.associatedUserId,
    this.associatedNoteId,
    this.associatedHost,
    required this.cachedAt,
    required this.lastAccessedAt,
    required this.accessCount,
    required this.fileSizeBytes,
  });

  factory ImageCacheRecord.fromMap(Map<String, dynamic> map) {
    return ImageCacheRecord(
      id: map['id'] as String,
      imageUrl: map['image_url'] as String,
      localPath: map['local_path'] as String?,
      cacheType: ImageCacheType.values.firstWhere(
        (e) => e.name == map['cache_type'],
        orElse: () => ImageCacheType.postImage,
      ),
      associatedUserId: map['associated_user_id'] as String?,
      associatedNoteId: map['associated_note_id'] as String?,
      associatedHost: map['associated_host'] as String?,
      cachedAt: DateTime.parse(map['cached_at'] as String),
      lastAccessedAt: DateTime.parse(map['last_accessed_at'] as String),
      accessCount: map['access_count'] as int,
      fileSizeBytes: map['file_size_bytes'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageUrl,
      'local_path': localPath,
      'cache_type': cacheType.name,
      'associated_user_id': associatedUserId,
      'associated_note_id': associatedNoteId,
      'associated_host': associatedHost,
      'cached_at': cachedAt.toIso8601String(),
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'access_count': accessCount,
      'file_size_bytes': fileSizeBytes,
    };
  }
}

/// Misskey 图片缓存数据库服务
///
/// 使用 SQLite 持久化存储图片缓存元数据，包括：
/// - 帖子图片、用户头像、横幅、表情、缩略图
/// - 记录关联的用户 UID，用于发帖人标记和互动关系比对
/// - 记录访问时间、次数，用于未来可能的 LRU 清理
class MisskeyImageCacheDatabase {
  static final MisskeyImageCacheDatabase _instance =
      MisskeyImageCacheDatabase._internal();
  factory MisskeyImageCacheDatabase() => _instance;
  MisskeyImageCacheDatabase._internal();

  Database? _database;
  static bool _ffiInitialized = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    await DatabasePathHelper.migrateIfNeeded();
    await DatabasePathHelper.ensurePermissions();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (!_ffiInitialized) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        _ffiInitialized = true;
      }
    }

    final dbPath = await DatabasePathHelper.getPath('misskey_image_cache.db');

    logger.info('MisskeyImageCacheDatabase: Opening database at $dbPath');

    final db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE image_cache (
        id TEXT PRIMARY KEY,
        image_url TEXT NOT NULL UNIQUE,
        local_path TEXT,
        cache_type TEXT NOT NULL,
        associated_user_id TEXT,
        associated_note_id TEXT,
        associated_host TEXT,
        cached_at TEXT NOT NULL,
        last_accessed_at TEXT NOT NULL,
        access_count INTEGER NOT NULL DEFAULT 0,
        file_size_bytes INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_cache_type ON image_cache(cache_type)
    ''');

    await db.execute('''
      CREATE INDEX idx_associated_user ON image_cache(associated_user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_last_accessed ON image_cache(last_accessed_at)
    ''');

    logger.info('MisskeyImageCacheDatabase: Database created successfully');
  }

  /// 插入或更新图片缓存记录
  Future<void> upsertCacheRecord(ImageCacheRecord record) async {
    final db = await database;
    await db.insert(
      'image_cache',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 根据 URL 获取缓存记录
  Future<ImageCacheRecord?> getCacheRecord(String imageUrl) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'image_cache',
      where: 'image_url = ?',
      whereArgs: [imageUrl],
    );
    if (maps.isEmpty) return null;
    return ImageCacheRecord.fromMap(maps.first);
  }

  /// 根据用户 UID 获取该用户的所有头像缓存记录
  Future<List<ImageCacheRecord>> getAvatarRecordsByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'image_cache',
      where: 'associated_user_id = ? AND cache_type = ?',
      whereArgs: [userId, ImageCacheType.avatar.name],
    );
    return maps.map((m) => ImageCacheRecord.fromMap(m)).toList();
  }

  /// 检查用户 UID 是否存在于缓存中（用于发帖人标记）
  Future<bool> isUserCached(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'image_cache',
      where: 'associated_user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// 更新访问统计
  Future<void> updateAccessStats(String imageUrl) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.rawUpdate(
      'UPDATE image_cache SET last_accessed_at = ?, access_count = access_count + 1 WHERE image_url = ?',
      [now, imageUrl],
    );
  }

  /// 删除缓存记录
  Future<void> deleteCacheRecord(String imageUrl) async {
    final db = await database;
    await db.delete(
      'image_cache',
      where: 'image_url = ?',
      whereArgs: [imageUrl],
    );
  }

  /// 获取所有缓存记录
  Future<List<ImageCacheRecord>> getAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'image_cache',
      orderBy: 'last_accessed_at DESC',
    );
    return maps.map((m) => ImageCacheRecord.fromMap(m)).toList();
  }

  /// 获取缓存总大小（字节）
  Future<int> getTotalCacheSize() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(file_size_bytes) as total FROM image_cache',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// 清理过期的缓存记录（根据最后访问时间）
  Future<void> cleanupExpiredCache({Duration maxAge = const Duration(days: 30)}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(maxAge);
    await db.delete(
      'image_cache',
      where: 'last_accessed_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
    logger.info('MisskeyImageCacheDatabase: Cleaned up expired cache records before $cutoffDate');
  }

  /// 清理所有 SQLite 缓存记录和关联的本地文件
  Future<void> clearAllSqliteCache() async {
    final db = await database;
    
    // 先获取所有记录，删除本地文件
    final records = await getAllRecords();
    for (final record in records) {
      if (record.localPath != null) {
        try {
          final file = File(record.localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          logger.warning('Failed to delete cached file: ${record.localPath}');
        }
      }
    }
    
    // 清空表
    await db.delete('image_cache');
    logger.info('MisskeyImageCacheDatabase: Cleared all SQLite cache records');
  }

  /// 按类型获取缓存记录数量
  Future<Map<ImageCacheType, int>> getRecordCountByType() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT cache_type, COUNT(*) as count FROM image_cache GROUP BY cache_type',
    );
    final Map<ImageCacheType, int> counts = {};
    for (final row in result) {
      final type = ImageCacheType.values.firstWhere(
        (e) => e.name == row['cache_type'],
        orElse: () => ImageCacheType.postImage,
      );
      counts[type] = row['count'] as int;
    }
    return counts;
  }

  /// 按类型获取缓存大小（字节）
  Future<Map<String, int>> getCacheSizeByType() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT cache_type, SUM(file_size_bytes) as total FROM image_cache GROUP BY cache_type',
    );
    final Map<String, int> sizes = {};
    for (final row in result) {
      final type = row['cache_type'] as String?;
      final total = row['total'] as int? ?? 0;
      if (type != null) {
        sizes[type] = total;
      }
    }
    return sizes;
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
