import 'dart:convert';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '/src/core/services/database_path_helper.dart';
import '/src/core/utils/logger.dart';

class TimelineCacheDatabase {
  static final TimelineCacheDatabase _instance =
      TimelineCacheDatabase._internal();
  factory TimelineCacheDatabase() => _instance;
  TimelineCacheDatabase._internal();

  Database? _database;
  static bool _ffiInitialized = false;

  static const _maxCacheAge = Duration(minutes: 30);

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

    final dbPath = await DatabasePathHelper.getPath('timeline_cache.db');

    logger.info('TimelineCacheDatabase: Opening database at $dbPath');

    final db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );

    return db;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加音频时长缓存表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS audio_length (
          file_id TEXT PRIMARY KEY,
          duration_ms INTEGER NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');

      // 添加文件大小缓存表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS file_size (
          file_id TEXT PRIMARY KEY,
          size_bytes INTEGER NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');

      logger.info('TimelineCacheDatabase: Upgraded to version 2');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE timeline_refresh (
        id TEXT PRIMARY KEY,
        timeline_type TEXT NOT NULL,
        last_refreshed_at TEXT NOT NULL,
        latest_note_id TEXT,
        cached_note_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_timeline_type ON timeline_refresh(timeline_type)
    ''');

    await db.execute('''
      CREATE TABLE cached_notes (
        note_id TEXT NOT NULL,
        timeline_type TEXT NOT NULL,
        note_json TEXT NOT NULL,
        cached_at TEXT NOT NULL,
        PRIMARY KEY (note_id, timeline_type)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_cached_notes_type ON cached_notes(timeline_type)
    ''');

    // 音频时长缓存表
    await db.execute('''
      CREATE TABLE audio_length (
        file_id TEXT PRIMARY KEY,
        duration_ms INTEGER NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');

    // 文件大小缓存表
    await db.execute('''
      CREATE TABLE file_size (
        file_id TEXT PRIMARY KEY,
        size_bytes INTEGER NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');

    logger.info('TimelineCacheDatabase: Created successfully');
  }

  String _buildId(String timelineType) => 'default_$timelineType';

  Future<DateTime?> getLastRefreshTime(String timelineType) async {
    final db = await database;
    final id = _buildId(timelineType);
    final maps = await db.query(
      'timeline_refresh',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DateTime.tryParse(maps.first['last_refreshed_at'] as String? ?? '');
  }

  Future<String?> getLatestNoteId(String timelineType) async {
    final db = await database;
    final id = _buildId(timelineType);
    final maps = await db.query(
      'timeline_refresh',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return maps.first['latest_note_id'] as String?;
  }

  Future<void> updateRefreshTime(
    String timelineType, {
    String? latestNoteId,
    int cachedNoteCount = 0,
  }) async {
    final db = await database;
    final id = _buildId(timelineType);
    await db.insert(
      'timeline_refresh',
      {
        'id': id,
        'timeline_type': timelineType,
        'last_refreshed_at': DateTime.now().toIso8601String(),
        'latest_note_id': latestNoteId,
        'cached_note_count': cachedNoteCount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> shouldRefresh(String timelineType) async {
    final lastTime = await getLastRefreshTime(timelineType);
    if (lastTime == null) return true;
    return DateTime.now().difference(lastTime) > _maxCacheAge;
  }

  Future<void> saveNotes(
      String timelineType, List<Map<String, dynamic>> noteMaps) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.delete('cached_notes',
          where: 'timeline_type = ?', whereArgs: [timelineType]);

      for (final noteMap in noteMaps) {
        await txn.insert('cached_notes', {
          'note_id': noteMap['id'] as String,
          'timeline_type': timelineType,
          'note_json': jsonEncode(noteMap),
          'cached_at': now,
        });
      }
    });

    await updateRefreshTime(
      timelineType,
      latestNoteId: noteMaps.isNotEmpty ? noteMaps.first['id'] as String : null,
      cachedNoteCount: noteMaps.length,
    );

    logger.info(
      'TimelineCacheDatabase: Saved ${noteMaps.length} notes for $timelineType',
    );
  }

  Future<List<Map<String, dynamic>>> getCachedAsMaps(
      String timelineType) async {
    final db = await database;
    final maps = await db.query(
      'cached_notes',
      where: 'timeline_type = ?',
      whereArgs: [timelineType],
      orderBy: 'cached_at DESC',
    );
    return maps.map((m) {
      final json = m['note_json'] as String;
      return jsonDecode(json) as Map<String, dynamic>;
    }).toList();
  }

  Future<int> getCachedNoteCount(String timelineType) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cached_notes WHERE timeline_type = ?',
      [timelineType],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getTotalApproximateSize() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(LENGTH(note_json)) as total FROM cached_notes',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<void> clearTimeline(String timelineType) async {
    final db = await database;
    await db.delete('cached_notes',
        where: 'timeline_type = ?', whereArgs: [timelineType]);
    await db.delete('timeline_refresh',
        where: 'timeline_type = ?', whereArgs: [timelineType]);
    logger.info('TimelineCacheDatabase: Cleared timeline $timelineType');
  }

  // ==================== 音频时长缓存 ====================

  /// 获取缓存的音频时长（毫秒）
  Future<int?> getAudioDuration(String fileId) async {
    final db = await database;
    final maps = await db.query(
      'audio_length',
      where: 'file_id = ?',
      whereArgs: [fileId],
    );
    if (maps.isEmpty) return null;
    return maps.first['duration_ms'] as int?;
  }

  /// 保存音频时长到缓存
  Future<void> saveAudioDuration(String fileId, int durationMs) async {
    final db = await database;
    await db.insert(
      'audio_length',
      {
        'file_id': fileId,
        'duration_ms': durationMs,
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== 文件大小缓存 ====================

  /// 获取缓存的文件大小（字节）
  Future<int?> getFileSize(String fileId) async {
    final db = await database;
    final maps = await db.query(
      'file_size',
      where: 'file_id = ?',
      whereArgs: [fileId],
    );
    if (maps.isEmpty) return null;
    return maps.first['size_bytes'] as int?;
  }

  /// 保存文件大小到缓存
  Future<void> saveFileSize(String fileId, int sizeBytes) async {
    final db = await database;
    await db.insert(
      'file_size',
      {
        'file_id': fileId,
        'size_bytes': sizeBytes,
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
