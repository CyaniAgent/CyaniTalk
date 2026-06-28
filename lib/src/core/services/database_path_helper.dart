import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '/src/core/utils/logger.dart';

class DatabasePathHelper {
  DatabasePathHelper._();

  static const _dbDirName = 'Databases';
  static const _oldAndroidBase = '/data/user/0/app.CyaniAgent.Talk/app_flutter';
  static const _newAndroidBase = '/data/user/0/app.CyaniAgent.Talk/databases';
  static const _externalSymlink =
      '/storage/emulated/0/Android/data/app.CyaniAgent.Talk/Databases';

  static Future<String> getDirectory() async {
    if (Platform.isAndroid) {
      return _ensureDir(_newAndroidBase);
    }

    if (Platform.isMacOS) {
      return _ensureDir('/Applications/app.CyaniAgent.Talk/$_dbDirName');
    }

    final appDir = await getApplicationSupportDirectory();
    return _ensureDir(p.join(appDir.path, _dbDirName));
  }

  static Future<String> getPath(String dbName) async {
    final dir = await getDirectory();
    return p.join(dir, dbName);
  }

  static Future<void> migrateIfNeeded() async {
    if (!Platform.isAndroid) return;

    final oldDir = Directory(_oldAndroidBase);
    final newDir = Directory(_newAndroidBase);

    if (!await oldDir.exists()) return;
    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }

    final entities = oldDir.listSync();
    for (final entity in entities) {
      if (entity is! File) {
        continue;
      }
      final name = p.basename(entity.path);
      if (!name.endsWith('.db') && !name.endsWith('.db-wal') &&
          !name.endsWith('.db-shm')) {
        continue;
      }

      final target = p.join(_newAndroidBase, name);
      if (await File(target).exists()) {
        continue;
      }

      try {
        await entity.copy(target);
        logger.info('DatabasePathHelper: Migrated $name to $target');
      } catch (e) {
        logger.warning('DatabasePathHelper: Failed to migrate $name: $e');
      }
    }

    if (await Directory(p.dirname(_externalSymlink)).exists()) {
      try {
        final link = Link(_externalSymlink);
        if (await link.exists()) {
          await link.delete();
        }
        await link.create(_newAndroidBase);
        logger.info('DatabasePathHelper: Created symlink $_externalSymlink');
      } catch (e) {
        logger.warning('DatabasePathHelper: Failed to create symlink: $e');
      }
    }
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
