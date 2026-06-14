import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final Color? color;
  final String? tooltip;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconSize = 20,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.onSurface;
    final Widget button = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Ink(
          decoration: ShapeDecoration(
            color: c.withAlpha(25),
            shape: const CircleBorder(),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Icon(icon, size: iconSize, color: c),
          ),
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
