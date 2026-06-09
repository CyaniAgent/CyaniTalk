import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      if (!_ffiInitialized) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        _ffiInitialized = true;
      }
    }

    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbDir.path, 'timeline_cache.db');

    logger.info('TimelineCacheDatabase: Opening database at $dbPath');

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

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
