import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/cache_manager.dart';
import '../utils/logger.dart';
import '../../features/auth/data/auth_repository.dart';

part 'app_reset_service.g.dart';

/// 应用程序重置服务
@riverpod
class AppReset extends _$AppReset {
  @override
  void build() {}

  /// 重置整个应用程序
  Future<void> resetApp() async {
    logger.warning('AppResetService: 开始全量重置应用程序数据...');

    try {
      // 1. 清除 SharedPreferences
      final prefs = ref.read(sharedPreferencesProvider);
      final bool prefsCleared = await prefs.clear();
      logger.info('AppResetService: SharedPreferences 清理状态: $prefsCleared');

      // 2. 清除 FlutterSecureStorage
      const secureStorage = FlutterSecureStorage();
      await secureStorage.deleteAll();
      logger.info('AppResetService: FlutterSecureStorage 已全部清空');

      // 3. 清除所有缓存文件
      await cacheManager.clearAllCache();
      logger.info('AppResetService: 本地缓存已清空');

      logger.warning('AppResetService: 应用程序重置完成！');
    } catch (e, stack) {
      logger.error('AppResetService: 重置过程中发生错误', e, stack);
      rethrow;
    }
  }
}
