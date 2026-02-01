// CyaniTalk应用程序的主组件文件
//
// 该文件包含应用程序的根组件CyaniTalkApp，负责配置应用程序的主题、路由和整体结构。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/core.dart';
import 'routing/router.dart';
import 'features/misskey/application/misskey_streaming_service.dart';
import 'features/profile/presentation/settings/appearance_page.dart';

/// CyaniTalk应用程序的根组件
class CyaniTalkApp extends ConsumerWidget {
  const CyaniTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.info('CyaniTalkApp: 初始化应用程序');

    final goRouter = ref.watch(goRouterProvider);
    logger.debug('CyaniTalkApp: 加载路由配置');

    // Get appearance settings
    final appearanceSettingsAsync = ref.watch(appearanceSettingsProvider);

    // Initialize Misskey Streaming Service at app level
    logger.debug('CyaniTalkApp: 初始化Misskey流媒体服务');
    ref.watch(misskeyStreamingServiceProvider);

    return appearanceSettingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        logger.error('CyaniTalkApp: 加载外观设置失败', error);
        // 使用默认设置
        final defaultSettings = const AppearanceSettings(
          isDarkMode: false,
          useDynamicColor: true,
          useCustomColor: false,
          primaryColor: null,
        );
        final theme = _buildTheme(defaultSettings);
        return MaterialApp.router(
          routerConfig: goRouter,
          title: 'CyaniTalk',
          theme: theme,
          darkTheme: _buildTheme(defaultSettings.copyWith(isDarkMode: true)),
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
      data: (appearanceSettings) {
        logger.debug(
          'CyaniTalkApp: 加载外观设置 - 深色模式: ${appearanceSettings.isDarkMode}, 动态色彩: ${appearanceSettings.useDynamicColor}',
        );

        // Build theme based on settings
        final theme = _buildTheme(appearanceSettings);

        logger.debug('CyaniTalkApp: 构建MaterialApp');
        return MaterialApp.router(
          routerConfig: goRouter,
          title: 'CyaniTalk',
          theme: theme,
          darkTheme: _buildTheme(appearanceSettings.copyWith(isDarkMode: true)),
          themeMode: appearanceSettings.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
    );
  }

  /// 构建主题
  ThemeData _buildTheme(AppearanceSettings settings) {
    // 使用自定义颜色或默认颜色
    final seedColor = settings.useCustomColor && settings.primaryColor != null
        ? settings.primaryColor!
        : const Color(0xFF39C5BB);

    return ThemeData(
      colorScheme: settings.useDynamicColor
          ? ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: settings.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
            )
          : ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: settings.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              // 固定色彩方案，不使用动态色彩
              primary: seedColor,
              secondary: const Color(0xFF6366F1),
            ),
      useMaterial3: true,
      fontFamily: 'MiSans',
    );
  }
}
