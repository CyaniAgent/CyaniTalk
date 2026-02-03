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
class CyaniTalkApp extends ConsumerStatefulWidget {
  const CyaniTalkApp({super.key});

  @override
  ConsumerState<CyaniTalkApp> createState() => _CyaniTalkAppState();
}

class _CyaniTalkAppState extends ConsumerState<CyaniTalkApp> {
  // 缓存主题，避免每次构建时都重新计算
  ThemeData? _cachedLightTheme;
  ThemeData? _cachedDarkTheme;
  AppearanceSettings? _cachedSettings;

  @override
  Widget build(BuildContext context) {
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
        const defaultSettings = AppearanceSettings(
          displayMode: ThemeMode.system,
          useDynamicColor: true,
          useCustomColor: false,
          primaryColor: null,
        );
        final theme = _buildTheme(defaultSettings, Brightness.light);
        return MaterialApp.router(
          routerConfig: goRouter,
          title: 'CyaniTalk',
          theme: theme,
          darkTheme: _buildTheme(defaultSettings, Brightness.dark),
          themeMode: defaultSettings.displayMode,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
      data: (appearanceSettings) {
        logger.debug(
          'CyaniTalkApp: 加载外观设置 - 显示模式: ${appearanceSettings.displayMode}, 动态色彩: ${appearanceSettings.useDynamicColor}',
        );

        // Build theme based on settings
        final theme = _buildTheme(appearanceSettings, Brightness.light);
        final darkTheme = _buildTheme(appearanceSettings, Brightness.dark);

        logger.debug('CyaniTalkApp: 构建MaterialApp');
        return MaterialApp.router(
          routerConfig: goRouter,
          title: 'CyaniTalk',
          theme: theme,
          darkTheme: darkTheme,
          themeMode: appearanceSettings.displayMode,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
    );
  }

  /// 构建主题
  /// 
  /// 根据用户的外观设置构建主题，支持深色模式、动态色彩和自定义颜色。
  /// 会缓存构建结果，避免重复计算。
  ThemeData _buildTheme(AppearanceSettings settings, Brightness brightness) {
    // 检查是否需要重新构建主题
    final isDark = brightness == Brightness.dark;
    final themeCache = isDark ? _cachedDarkTheme : _cachedLightTheme;
    
    // 如果设置没有变化且主题已缓存，直接返回缓存的主题
    if (_cachedSettings == settings && themeCache != null) {
      return themeCache;
    }

    // 使用自定义颜色或默认颜色
    final seedColor = settings.useCustomColor && settings.primaryColor != null
        ? settings.primaryColor!
        : const Color(0xFF39C5BB);

    final theme = ThemeData(
      colorScheme: settings.useDynamicColor
          ? ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: brightness,
            )
          : ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: brightness,
              // 固定色彩方案，不使用动态色彩
              primary: seedColor,
              secondary: const Color(0xFF6366F1),
            ),
      useMaterial3: true,
      fontFamily: 'MiSans',
    );

    // 缓存主题和设置
    if (isDark) {
      _cachedDarkTheme = theme;
    } else {
      _cachedLightTheme = theme;
    }
    _cachedSettings = settings;

    return theme;
  }
}