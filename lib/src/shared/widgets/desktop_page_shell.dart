import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/src/features/profile/presentation/settings/appearance_page.dart';
import 'custom_title_bar.dart';

class DesktopPageShell extends ConsumerWidget {
  final Widget child;

  const DesktopPageShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    if (!isDesktop) return child;

    final useCustomTitleBar =
        ref.watch(appearanceSettingsProvider).asData?.value.useCustomTitleBar ??
            true;
    if (!useCustomTitleBar) return child;

    return Column(
      children: [
        const CustomTitleBar(),
        Expanded(child: child),
      ],
    );
  }
}
