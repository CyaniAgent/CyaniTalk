import 'package:flutter/material.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

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
    return LoadingIndicatorM3E(
      variant: contained
          ? LoadingIndicatorM3EVariant.contained
          : LoadingIndicatorM3EVariant.defaultStyle,
      color: color,
      constraints: BoxConstraints.tight(Size(size, size)),
    );
  }
}
