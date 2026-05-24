import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Cyani loading indicator widget with modern geometric staggered animation.
///
/// Features three spinning, scaling, bouncing diamonds in Miku Green (#39C5BB)
/// representing rhythm nodes.
class CyaniLoadingIndicator extends StatefulWidget {
  /// Dimension constraint
  final double size;
  
  /// Base theme color of the loading shapes
  final Color? color;

  const CyaniLoadingIndicator({
    super.key,
    this.size = 60,
    this.color,
  });

  @override
  State<CyaniLoadingIndicator> createState() => _CyaniLoadingIndicatorState();
}

class _CyaniLoadingIndicatorState extends State<CyaniLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? const Color(0xFF39C5BB); // Miku Green!
    
    return SizedBox(
      width: widget.size * 2,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              // Staggered delay based on index
              final delay = index * 0.2;
              double progress = (_controller.value - delay) % 1.0;
              if (progress < 0) progress += 1.0;
              
              // Wave patterns
              final waveSin = math.sin(progress * math.pi);
              final scale = 0.6 + 0.55 * waveSin;
              final opacity = (0.3 + 0.7 * waveSin).clamp(0.0, 1.0);
              final rotation = progress * 2.0 * math.pi;

              return Transform.translate(
                offset: Offset(0, -12 * waveSin),
                child: Transform.rotate(
                  angle: rotation + (math.pi / 4), // Rotate 45deg for diamond + spin
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: widget.size * 0.28,
                        height: widget.size * 0.28,
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(widget.size * 0.05),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withAlpha((0.4 * 255).round()),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
