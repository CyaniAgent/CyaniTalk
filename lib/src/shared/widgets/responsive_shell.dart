import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/core/navigation/navigation.dart';
import '/src/core/navigation/navigation_element.dart';
import '/src/features/profile/presentation/settings/appearance_page.dart';
import 'custom_title_bar.dart';
import 'root_navigation_drawer.dart';

const double _kDrawerWidth = 304.0;

class ResponsiveShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ResponsiveShell({required this.navigationShell, super.key});

  @override
  ConsumerState<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends ConsumerState<ResponsiveShell>
    with TickerProviderStateMixin {
  bool _isTransitioning = false;
  Timer? _transitionTimer;
  late AnimationController _drawerAnimationController;

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Attach to NavigationController after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(navigationControllerProvider.notifier)
          .attachAnimationController(_drawerAnimationController);
    });
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void _onRootSelected(int index, dynamic navigationSettings) {
    setState(() => _isTransitioning = true);
    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isTransitioning = false);
    });

    int branchIndex = NavigationService.mapDisplayIndexToBranchIndex(
      index,
      navigationSettings,
    );
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationSettingsAsync = ref.watch(navigationSettingsProvider);
    final appearanceAsync = ref.watch(appearanceSettingsProvider);

    return navigationSettingsAsync.when(
      loading: () => const Scaffold(body: SizedBox.shrink()),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (navigationSettings) {
        final rootItemElements = navigationSettings.elements
            .where(
              (element) =>
                  element.type == NavigationElementType.item &&
                  element is NavigationItemElement &&
                  element.item.isEnabled &&
                  element.item.id != 'me',
            )
            .cast<NavigationItemElement>()
            .toList();

        final rootItems = rootItemElements.map((e) => e.item).toList();

        if (rootItems.isEmpty) {
          return Scaffold(
            body: Center(child: Text('navigation_no_items'.tr())),
          );
        }

        int selectedRootIndex = NavigationService.mapBranchIndexToDisplayIndex(
          widget.navigationShell.currentIndex,
          navigationSettings,
        );

        final bool isMeSelected =
            widget.navigationShell.currentIndex ==
            NavigationService.getBranchIndexForItem('me');

        if (isMeSelected || selectedRootIndex >= rootItems.length) {
          selectedRootIndex = -1;
        }

        final isDesktop =
            Platform.isWindows || Platform.isLinux || Platform.isMacOS;
        final useCustomTitleBar = isDesktop &&
            (appearanceAsync.asData?.value.useCustomTitleBar ?? true);

        return Column(
          children: [
            if (useCustomTitleBar) const CustomTitleBar(),
            Expanded(
              child: Stack(
                children: [
                  // Layer 1: Scaffold (main content)
                  Scaffold(
                    body: ExcludeSemantics(
                      excluding: _isTransitioning,
                      child: widget.navigationShell,
                    ),
                  ),

                  // Layer 2: Dim overlay (below title bar z-level)
                  if (useCustomTitleBar)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedBuilder(
                        animation: _drawerAnimationController,
                        builder: (context, child) {
                          final opacity = _drawerAnimationController.value * 0.5;
                          if (opacity <= 0) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: () => ref
                                .read(navigationControllerProvider.notifier)
                                .closeDrawer(),
                            child: Container(
                              color: Colors.black.withValues(alpha: opacity),
                            ),
                          );
                        },
                      ),
                    ),

                  // Layer 3: Drawer overlay (left side, full height, above dim)
                  Positioned(
                    top: 0,
                    left: 0,
                    bottom: 0,
                    width: _kDrawerWidth,
                    child: AnimatedBuilder(
                      animation: _drawerAnimationController,
                      builder: (context, child) {
                        final offset = Offset.lerp(
                          const Offset(-1, 0),
                          Offset.zero,
                          _drawerAnimationController.value,
                        )!;
                        return FractionalTranslation(
                          translation: offset,
                          child: child,
                        );
                      },
                      child: RootNavigationDrawer(
                        selectedRootIndex: selectedRootIndex,
                        onRootSelected: (index) =>
                            _onRootSelected(index, navigationSettings),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
