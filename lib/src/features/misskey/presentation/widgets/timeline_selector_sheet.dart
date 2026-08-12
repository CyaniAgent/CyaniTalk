import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import '/src/shared/widgets/circle_icon_button.dart';

/// 时间线选择器 Sheet
///
/// 用于选择时间线类型（全球、主页、本地、社交）
/// 显示在线人数和各时间线的描述
class TimelineSelectorSheet extends ConsumerWidget {
  final String currentType;
  final ValueChanged<String> onTypeSelected;

  const TimelineSelectorSheet({
    super.key,
    required this.currentType,
    required this.onTypeSelected,
  });

  static void show(
    BuildContext context, {
    required String currentType,
    required ValueChanged<String> onTypeSelected,
  }) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    if (isWideScreen) {
      _showSideSheet(context, currentType: currentType, onTypeSelected: onTypeSelected);
    } else {
      _showBottomSheet(context, currentType: currentType, onTypeSelected: onTypeSelected);
    }
  }

  static void _showBottomSheet(
    BuildContext context, {
    required String currentType,
    required ValueChanged<String> onTypeSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => _TimelineSelectorContent(
          currentType: currentType,
          onTypeSelected: onTypeSelected,
          scrollController: scrollController,
        ),
      ),
    );
  }

  static void _showSideSheet(
    BuildContext context, {
    required String currentType,
    required ValueChanged<String> onTypeSelected,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 8,
            child: SizedBox(
              width: 320,
              height: double.infinity,
              child: _TimelineSelectorContent(
                currentType: currentType,
                onTypeSelected: onTypeSelected,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TimelineSelectorContent(
      currentType: currentType,
      onTypeSelected: onTypeSelected,
    );
  }
}

class _TimelineSelectorContent extends ConsumerWidget {
  final String currentType;
  final ValueChanged<String> onTypeSelected;
  final ScrollController? scrollController;

  const _TimelineSelectorContent({
    required this.currentType,
    required this.onTypeSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onlineUsersAsync = ref.watch(misskeyOnlineUsersProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖动指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题和在线人数
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'timeline_selector_title'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 在线人数
                onlineUsersAsync.when(
                  data: (count) => _buildOnlineCount(context, theme, colorScheme, count),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: Icons.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 时间线选项列表
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                _buildTimelineOption(
                  context,
                  type: 'Global',
                  icon: Icons.public_rounded,
                  color: colorScheme.secondary,
                  label: 'timeline_global'.tr(),
                  description: 'timeline_global_desc'.tr(),
                ),
                const SizedBox(height: 12),
                _buildTimelineOption(
                  context,
                  type: 'Home',
                  icon: Icons.home_rounded,
                  color: colorScheme.primary,
                  label: 'timeline_home'.tr(),
                  description: 'timeline_home_desc'.tr(),
                ),
                const SizedBox(height: 12),
                _buildTimelineOption(
                  context,
                  type: 'Local',
                  icon: Icons.language_rounded,
                  color: colorScheme.tertiary,
                  label: 'timeline_local'.tr(),
                  description: 'timeline_local_desc'.tr(),
                ),
                const SizedBox(height: 12),
                _buildTimelineOption(
                  context,
                  type: 'Social',
                  icon: Icons.group_rounded,
                  color: colorScheme.primaryContainer,
                  label: 'timeline_social'.tr(),
                  description: 'timeline_social_desc'.tr(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineCount(BuildContext context, ThemeData theme, ColorScheme colorScheme, int count) {
    final suffix = switch (context.locale.languageCode) {
      'zh' => '人在线',
      'ja' => '人オンライン',
      _ => ' online',
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulsingOnlineDot(color: colorScheme.primary),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              TextSpan(
                text: count.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: suffix,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineOption(
    BuildContext context, {
    required String type,
    required IconData icon,
    required Color color,
    required String label,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentType == type;

    return GestureDetector(
      onTap: () {
        onTypeSelected(type);
        Navigator.of(context).pop();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(30)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : colorScheme.outlineVariant.withAlpha(50),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color.withAlpha(50) : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// 脉动在线圆点
class _PulsingOnlineDot extends StatefulWidget {
  final Color color;
  const _PulsingOnlineDot({required this.color});

  @override
  State<_PulsingOnlineDot> createState() => _PulsingOnlineDotState();
}

class _PulsingOnlineDotState extends State<_PulsingOnlineDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withAlpha((_animation.value * 255).toInt()),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
