import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import '/src/core/navigation/navigation.dart';

class ComingSoonPage extends ConsumerWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Breakpoints.small.isActive(context)
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => ref
                    .read(navigationControllerProvider.notifier)
                    .openDrawer(),
              )
            : null,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset('assets/images/coming-soon-bg.png', fit: BoxFit.cover),

          // Dark overlay for better text readability
          Container(color: Colors.black.withValues(alpha: 0.4)),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Coming Soon',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.surface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'feature_under_development'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
