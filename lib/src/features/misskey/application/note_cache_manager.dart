import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyanitalk/src/features/misskey/domain/note.dart';
import '../../../core/core.dart';

/// 笔记缓存项
class NoteCacheItem {
  /// 笔记数据
  Note note;

  /// 缓存时间
  DateTime cachedAt;

  /// 是否已从服务器验证过
  bool isValidated;

  NoteCacheItem({
    required this.note,
    required this.cachedAt,
    this.isValidated = false,
  });

  /// 检查缓存是否过期（超过5分钟）
  bool get isExpired {
    return DateTime.now().difference(cachedAt) > const Duration(minutes: 5);
  }
}

/// 笔记缓存管理器
///
/// 负责管理笔记数据的缓存，支持后台比对和自动更新。
/// 使用混合缓存策略：内存中保留最近访问的笔记，超过限制时将旧笔记移到持久化存储。
/// 最大内存缓存 100 条笔记，持久化存储最多 1000 条笔记。
/// 支持持久化存储，应用重启后缓存依然有效。
class NoteCacheManager {
  /// 内存缓存存储，key为笔记ID
  final Map<String, NoteCacheItem> _cache = {};

  /// 最大内存缓存数量
  static const int _maxMemoryCacheSize = 100;

  /// 最大持久化缓存数量
  static const int _maxPersistentCacheSize = 1000;

  /// 缓存访问顺序，用于LRU淘汰
  final List<String> _accessOrder = [];

  /// 比对定时器
  Timer? _validationTimer;

  /// 最后比对时间
  DateTime _lastValidation = DateTime.now();

  /// 最小比对间隔（30秒）
  static const Duration _minValidationInterval = Duration(seconds: 30);

  /// SharedPreferences 实例
  SharedPreferences? _prefs;

  /// 持久化缓存存储的key
  static const String _persistentCacheKey = 'misskey_note_persistent_cache';

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化缓存管理器
  ///
  /// 从持久化存储加载缓存数据
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadFromStorage();
    _isInitialized = true;
  }

  /// 从持久化存储加载缓存
  Future<void> _loadFromStorage() async {
    if (_prefs == null) return;

    try {
      final persistentCacheJson = _prefs!.getString(_persistentCacheKey);

      if (persistentCacheJson != null && persistentCacheJson.isNotEmpty) {
        await _loadCacheFromJson(persistentCacheJson);
      }
    } catch (e) {
      logger.warning('NoteCacheManager: Failed to load cache from storage: $e');
      _cache.clear();
      _accessOrder.clear();
    }
  }

  /// 从JSON加载缓存
  Future<void> _loadCacheFromJson(String cacheJson) async {
    try {
      final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
      final notesData = cacheData['notes'] as Map<String, dynamic>?;
      final accessOrderData = cacheData['accessOrder'] as List<dynamic>?;

      if (notesData != null) {
        for (final entry in notesData.entries) {
          try {
            final noteJson = entry.value as Map<String, dynamic>;
            final note = Note.fromJson(noteJson);
            final cachedAt = DateTime.parse(noteJson['cachedAt'] as String);
            final isValidated = noteJson['isValidated'] as bool? ?? false;

            _cache[entry.key] = NoteCacheItem(
              note: note,
              cachedAt: cachedAt,
              isValidated: isValidated,
            );
          } catch (e) {
            continue;
          }
        }
      }

      if (accessOrderData != null) {
        _accessOrder.addAll(accessOrderData.cast<String>());
      }
    } catch (e) {
      logger.warning('NoteCacheManager: Failed to parse cache JSON: $e');
    }
  }

  /// 立即保存所有笔记到持久化存储
  ///
  /// 确保所有笔记都被保存，防止应用被强制关闭导致数据丢失
  Future<void> saveAllToStorage() async {
    if (_prefs == null) return;

    try {
      final allCacheData = <String, dynamic>{};
      final allAccessOrder = <String>[];

      for (final noteId in _accessOrder) {
        final cacheItem = _cache[noteId];
        if (cacheItem != null) {
          try {
            final noteJson = cacheItem.note.toJson();
            noteJson['cachedAt'] = cacheItem.cachedAt.toIso8601String();
            noteJson['isValidated'] = cacheItem.isValidated;
            allCacheData[noteId] = noteJson;
            allAccessOrder.add(noteId);
          } catch (e) {
            continue;
          }
        }
      }

      final allCacheJson = {
        'notes': allCacheData,
        'accessOrder': allAccessOrder,
      };

      await _prefs!.setString(_persistentCacheKey, jsonEncode(allCacheJson));
      logger.debug(
        'NoteCacheManager: Saved all ${allCacheData.length} notes to persistent storage',
      );
    } catch (e) {
      logger.warning(
        'NoteCacheManager: Failed to save all notes to storage: $e',
      );
    }
  }

  /// 获取缓存中的笔记
  Note? getNote(String noteId) {
    final cacheItem = _cache[noteId];
    if (cacheItem == null) return null;

    _updateAccessOrder(noteId);
    return cacheItem.note;
  }

  /// 获取缓存中的所有笔记（仅内存缓存）
  List<Note> getAllNotes() {
    final notes = <Note>[];
    final startIndex = _accessOrder.length > _maxMemoryCacheSize
        ? _accessOrder.length - _maxMemoryCacheSize
        : 0;
    final notesToKeep = _accessOrder.sublist(startIndex);

    for (final noteId in notesToKeep) {
      final note = getNote(noteId);
      if (note != null) {
        notes.add(note);
      }
    }

    notes.sort((a, b) => b.id.compareTo(a.id));
    return notes;
  }

  /// 从持久化存储加载笔记
  Future<List<Note>> loadNotesFromPersistentStorage() async {
    if (_prefs == null) return [];

    try {
      final persistentCacheJson = _prefs!.getString(_persistentCacheKey);
      if (persistentCacheJson == null || persistentCacheJson.isEmpty) return [];

      final cacheData = jsonDecode(persistentCacheJson) as Map<String, dynamic>;
      final notesData = cacheData['notes'] as Map<String, dynamic>?;
      final accessOrderData = cacheData['accessOrder'] as List<dynamic>?;

      if (notesData == null) return [];

      final notes = <Note>[];

      if (accessOrderData != null && accessOrderData.isNotEmpty) {
        for (final noteId in accessOrderData.cast<String>()) {
          final noteJson = notesData[noteId] as Map<String, dynamic>?;
          if (noteJson != null) {
            try {
              final note = Note.fromJson(noteJson);
              notes.add(note);
            } catch (e) {
              continue;
            }
          }
        }
      }

      notes.sort((a, b) => b.id.compareTo(a.id));
      return notes;
    } catch (e) {
      logger.warning(
        'NoteCacheManager: Failed to load notes from persistent storage: $e',
      );
      return [];
    }
  }

  /// 获取缓存中的笔记（按ID列表）
  List<Note> getNotesByIds(List<String> noteIds) {
    final notes = <Note>[];
    for (final noteId in noteIds) {
      final note = getNote(noteId);
      if (note != null) {
        notes.add(note);
      }
    }
    return notes;
  }

  /// 添加或更新笔记缓存
  void putNote(Note note) {
    final noteId = note.id;

    if (_cache.containsKey(noteId)) {
      _cache[noteId]!.note = note;
      _cache[noteId]!.cachedAt = DateTime.now();
    } else {
      if (_cache.length >= _maxMemoryCacheSize + _maxPersistentCacheSize) {
        _evictLRU();
      }
      _cache[noteId] = NoteCacheItem(note: note, cachedAt: DateTime.now());
    }

    _updateAccessOrder(noteId);

    saveAllToStorage();
  }

  /// 批量添加笔记到缓存
  void putNotes(List<Note> notes) {
    for (final note in notes) {
      putNote(note);
    }
  }

  /// 从缓存中移除笔记
  void removeNote(String noteId) {
    _cache.remove(noteId);
    _accessOrder.remove(noteId);
    saveAllToStorage();
  }

  /// 清空所有缓存
  void clear() {
    _cache.clear();
    _accessOrder.clear();
    saveAllToStorage();
  }

  /// 获取缓存大小
  int get size => _cache.length;

  /// 检查笔记是否在缓存中
  bool hasNote(String noteId) {
    return _cache.containsKey(noteId);
  }

  /// 获取需要验证的笔记列表
  ///
  /// 返回缓存中未验证或已过期的笔记ID列表
  List<String> getNotesToValidate() {
    final notesToValidate = <String>[];

    for (final entry in _cache.entries) {
      final cacheItem = entry.value;

      if (!cacheItem.isValidated || cacheItem.isExpired) {
        notesToValidate.add(entry.key);
      }
    }

    return notesToValidate;
  }

  /// 标记笔记为已验证
  void markAsValidated(String noteId) {
    final cacheItem = _cache[noteId];
    if (cacheItem != null) {
      cacheItem.isValidated = true;
      cacheItem.cachedAt = DateTime.now();
    }
  }

  /// 批量标记笔记为已验证
  void markAsValidatedBatch(List<String> noteIds) {
    for (final noteId in noteIds) {
      markAsValidated(noteId);
    }
  }

  /// 更新访问顺序（LRU）
  void _updateAccessOrder(String noteId) {
    _accessOrder.remove(noteId);
    _accessOrder.add(noteId);
  }

  /// 淘汰最近最少使用的缓存项
  void _evictLRU() {
    if (_accessOrder.isEmpty) return;

    final lruNoteId = _accessOrder.removeAt(0);
    _cache.remove(lruNoteId);
  }

  /// 启动后台比对定时器
  ///
  /// 每60秒执行一次比对，检查缓存的笔记是否有更新
  /// @param validationCallback 比对回调函数，接收需要验证的笔记ID列表
  void startValidationTimer(
    Future<void> Function(List<String> noteIds) validationCallback,
  ) {
    _validationTimer?.cancel();
    _validationTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      await _performValidation(validationCallback);
    });
  }

  /// 停止后台比对定时器
  void stopValidationTimer() {
    _validationTimer?.cancel();
    _validationTimer = null;
  }

  /// 执行比对操作
  Future<void> _performValidation(
    Future<void> Function(List<String> noteIds) validationCallback,
  ) async {
    final now = DateTime.now();
    final timeSinceLastValidation = now.difference(_lastValidation);

    if (timeSinceLastValidation < _minValidationInterval) {
      return;
    }

    _lastValidation = now;

    final notesToValidate = getNotesToValidate();
    if (notesToValidate.isEmpty) return;

    try {
      await validationCallback(notesToValidate);
    } catch (e) {
      rethrow;
    }
  }

  /// 清理过期缓存
  ///
  /// 移除所有已过期的缓存项
  void cleanupExpiredCache() {
    final expiredNoteIds = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredNoteIds.add(entry.key);
      }
    }

    for (final noteId in expiredNoteIds) {
      removeNote(noteId);
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    final validatedCount = _cache.values
        .where((item) => item.isValidated)
        .length;
    final expiredCount = _cache.values.where((item) => item.isExpired).length;

    return {
      'total': _cache.length,
      'validated': validatedCount,
      'expired': expiredCount,
      'unvalidated': _cache.length - validatedCount,
    };
  }
}
