import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatefulWidget {
  const CustomTitleBar({super.key});

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar> with WindowListener {
  bool _isMaximized = false;
  bool get _isDesktop => Platform.isWindows || Platform.isLinux;

  @override
  void initState() {
    super.initState();
    if (_isDesktop) {
      windowManager.addListener(this);
      windowManager.isMaximized().then((v) {
        if (mounted) setState(() => _isMaximized = v);
      });
    }
  }

  @override
  void dispose() {
    if (_isDesktop) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    if (mounted) setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) setState(() => _isMaximized = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDesktop) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.colorScheme.surface;
    final iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final hoverBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 36,
        color: bgColor,
        child: Row(
          children: [
            _TitleBarButton(
              icon: Icons.close_rounded,
              iconSize: 18,
              iconColor: iconColor,
              hoverBg: Colors.redAccent,
              hoverIconColor: Colors.white,
              tooltip: '关闭',
              onTap: () => windowManager.close(),
            ),
            const Spacer(),
            _TitleBarButton(
              icon: Icons.minimize_rounded,
              iconSize: 20,
              iconColor: iconColor,
              hoverBg: hoverBg,
              tooltip: '最小化',
              onTap: () => windowManager.minimize(),
            ),
            _TitleBarButton(
              icon: _isMaximized
                  ? Icons.filter_none_rounded
                  : Icons.crop_square_rounded,
              iconSize: _isMaximized ? 18 : 16,
              iconColor: iconColor,
              hoverBg: hoverBg,
              tooltip: _isMaximized ? '还原' : '最大化',
              onTap: () {
                if (_isMaximized) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleBarButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Color hoverBg;
  final Color? hoverIconColor;
  final String tooltip;
  final VoidCallback onTap;

  const _TitleBarButton({
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.hoverBg,
    this.hoverIconColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _isHovered = false;
  bool _showTooltip = false;

  void _showTooltipPopup() {
    if (_showTooltip) return;
    setState(() => _showTooltip = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showTooltip = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _showTooltipPopup();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _showTooltip = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 46,
              height: 36,
              alignment: Alignment.center,
              color: _isHovered ? widget.hoverBg : Colors.transparent,
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: _isHovered
                    ? (widget.hoverIconColor ?? widget.iconColor)
                    : widget.iconColor,
              ),
            ),
            if (_showTooltip)
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.tooltip,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}