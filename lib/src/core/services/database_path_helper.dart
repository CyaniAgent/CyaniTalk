import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '/src/core/utils/logger.dart';

class DatabasePathHelper {
  DatabasePathHelper._();

  static const _dbDirName = 'Databases';

  static Future<String> getDirectory() async {
    final appDir = await getApplicationSupportDirectory();
    return _ensureDir(p.join(appDir.path, _dbDirName));
  }

  static Future<String> getPath(String dbName) async {
    final dir = await getDirectory();
    return p.join(dir, dbName);
  }

  static Future<void> migrateIfNeeded() async {
    // 统一使用 path_provider，无需特殊迁移
    return;
  }

  static Future<void> ensurePermissions() async {
    if (Platform.isWindows) return;

    try {
      final dir = await getDirectory();
      await Process.run('chmod', ['-R', '766', dir]);
      logger.info('DatabasePathHelper: Set 766 permissions on $dir');
    } catch (e) {
      logger.warning('DatabasePathHelper: Failed to set permissions: $e');
    }
  }

  static Future<String> _ensureDir(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      logger.info('DatabasePathHelper: Created directory $path');
    }
    return path;
  }
}
