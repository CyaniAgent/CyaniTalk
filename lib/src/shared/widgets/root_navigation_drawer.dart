import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/navigation/navigation.dart';
import '../../core/navigation/sub_navigation_notifier.dart';
import 'user_navigation_header.dart';

class RootNavigationDrawer extends ConsumerWidget {
  final int selectedRootIndex;
  final Function(int) onRootSelected;

  const RootNavigationDrawer({
    super.key,
    required this.selectedRootIndex,
    required this.onRootSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationSettings = ref.watch(navigationSettingsProvider).value;
    
    // We only care about the first 4 roots: Misskey, Flarum, Drive, Messages
    // 'me' is now handled by the header.
    final rootItems = navigationSettings?.items
        .where((item) => item.isEnabled && item.id != 'me')
        .toList() ?? [];

    return NavigationDrawer(
      selectedIndex: -1, // We'll manage highlighting manually to support hierarchical view
      onDestinationSelected: (index) {
        // This is called for any destination. We need to distinguish between root and sub.
      },
      children: [
        const UserNavigationHeader(isDrawer: true),
        const Divider(indent: 12, endIndent: 12),
        
        // Root Sections
        for (int i = 0; i < rootItems.length; i++) ...[
          _buildRootSection(context, ref, rootItems[i], i),
        ],
      ],
    );
  }

  Widget _buildRootSection(BuildContext context, WidgetRef ref, NavigationItem rootItem, int index) {
    final isSelected = index == selectedRootIndex;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom root item implementation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: InkWell(
            onTap: () => onRootSelected(index),
            borderRadius: BorderRadius.circular(32),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.secondaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? rootItem.selectedIcon : rootItem.icon,
                    color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rootItem.title,
                      style: TextStyle(
                        color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Sub-navigation for the selected root
        if (isSelected) 
          _buildSubNavigation(context, ref, rootItem.id),
        
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSubNavigation(BuildContext context, WidgetRef ref, String rootId) {
    if (rootId == 'misskey') {
      return _buildMisskeySubs(context, ref);
    } else if (rootId == 'flarum') {
      return _buildForumSubs(context, ref);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMisskeySubs(BuildContext context, WidgetRef ref) {
    final selectedSub = ref.watch(misskeySubIndexProvider);

    final subs = [
      {'icon': Icons.timeline, 'label': 'misskey_drawer_timeline'.tr()},
      {'icon': Icons.collections_bookmark, 'label': 'misskey_drawer_clips'.tr()},
      {'icon': Icons.satellite_alt, 'label': 'misskey_drawer_antennas'.tr()},
      {'icon': Icons.hub, 'label': 'misskey_drawer_channels'.tr()},
      {'icon': Icons.explore, 'label': 'misskey_drawer_explore'.tr()},
      {'icon': Icons.person_add, 'label': 'misskey_drawer_follow_requests'.tr()},
      {'icon': Icons.campaign, 'label': 'misskey_drawer_announcements'.tr()},
      {'icon': Icons.terminal, 'label': 'misskey_drawer_aiscript_console'.tr()},
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 12),
      child: Column(
        children: [
          for (int i = 0; i < subs.length; i++)
            _buildSubItem(
              context,
              icon: subs[i]['icon'] as IconData,
              label: subs[i]['label'] as String,
              isSelected: selectedSub == i,
              onTap: () {
                ref.read(misskeySubIndexProvider.notifier).set(i);
                Navigator.of(context).maybePop();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildForumSubs(BuildContext context, WidgetRef ref) {
    final selectedSub = ref.watch(forumSubIndexProvider);

    final subs = [
      {'icon': Icons.forum, 'label': 'flarum_drawer_discussions'.tr()},
      {'icon': Icons.label, 'label': 'flarum_drawer_tags'.tr()},
      {'icon': Icons.notifications, 'label': 'flarum_drawer_notifications'.tr()},
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 12),
      child: Column(
        children: [
          for (int i = 0; i < subs.length; i++)
            _buildSubItem(
              context,
              icon: subs[i]['icon'] as IconData,
              label: subs[i]['label'] as String,
              isSelected: selectedSub == i,
              onTap: () {
                ref.read(forumSubIndexProvider.notifier).set(i);
                Navigator.of(context).maybePop();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surfaceContainerHighest : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
