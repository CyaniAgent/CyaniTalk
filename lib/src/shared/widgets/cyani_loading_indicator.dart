import 'package:flutter/material.dart';
import 'package:m3e_core/m3e_core.dart';

class CyaniLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final bool contained;

  const CyaniLoadingIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.contained = false,
  });

  @override
  Widget build(BuildContext context) {
    if (contained) {
      return M3EContainedLoadingIndicator(
        width: size,
        height: size,
        padding: EdgeInsets.zero,
        indicatorColor: color,
      );
    }
    return M3ELoadingIndicator(
      color: color,
      constraints: BoxConstraints.tight(Size(size, size)),
    );
  }
}
