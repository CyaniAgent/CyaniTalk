import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/router.dart';

class CyaniTalkApp extends ConsumerWidget {
  const CyaniTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'CyaniTalk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
