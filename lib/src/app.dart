// CyaniTalk应用程序的主组件文件
//
// 该文件包含应用程序的根组件CyaniTalkApp，负责配置应用程序的主题、路由和整体结构。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/core.dart';
import 'routing/router.dart';
import 'features/misskey/application/misskey_streaming_service.dart';

/// CyaniTalk应用程序的根组件
class CyaniTalkApp extends ConsumerWidget {
  const CyaniTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.info('CyaniTalkApp: 初始化应用程序');
    
    final goRouter = ref.watch(goRouterProvider);
    logger.debug('CyaniTalkApp: 加载路由配置');
    
    // Initialize Misskey Streaming Service at app level
    logger.debug('CyaniTalkApp: 初始化Misskey流媒体服务');
    ref.watch(misskeyStreamingServiceProvider);

    logger.debug('CyaniTalkApp: 构建MaterialApp');
    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'CyaniTalk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF39C5BB)),
        useMaterial3: true,
        fontFamily: 'MiSans',
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
