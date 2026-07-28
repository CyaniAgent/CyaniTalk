import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

/// Material 3 Expressive Switch — fixed thumb with ✓/× icons.
///
/// Uses [CustomPainter] + [repaint] parameter for optimal 60fps animation.
/// Track: 52×32dp, thumb: fixed 24dp, position-only animation (no relayout).
class ExpressiveSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ExpressiveSwitch({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  State<ExpressiveSwitch> createState() => _ExpressiveSwitchState();
}

class _ExpressiveSwitchState extends State<ExpressiveSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final tokens = context.m3eSwitch;
      _controller = AnimationController(
        vsync: this,
        duration: tokens.toggleDuration,
        value: widget.value ? 1.0 : 0.0,
      );
    }
  }

  @override
  void didUpdateWidget(ExpressiveSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && _initialized) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.m3eSwitch;
    final disabled = widget.onChanged == null;

    return Semantics(
      toggled: widget.value,
      label: widget.value ? 'ON' : 'OFF',
      child: GestureDetector(
        onTap: disabled ? null : () => widget.onChanged!.call(!widget.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SwitchPainter(
                    progress: _controller.value,
                    tokens: tokens,
                    colorScheme: colorScheme,
                    disabled: disabled,
                    value: widget.value,
                  ),
                  size: Size(tokens.trackWidth, tokens.trackHeight),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Optimized painter — only repaints when animation value changes.
class _SwitchPainter extends CustomPainter {
  final double progress;
  final M3ESwitchTokens tokens;
  final ColorScheme colorScheme;
  final bool disabled;
  final bool value;

  _SwitchPainter({
    required this.progress,
    required this.tokens,
    required this.colorScheme,
    required this.disabled,
    required this.value,
  });

  // ── Pre-computed colors (avoids allocation per frame) ──
  Color get _trackOn => disabled ? colorScheme.onSurface.withAlpha(25) : colorScheme.primary;
  Color get _trackOff => disabled ? colorScheme.onSurface.withAlpha(25) : colorScheme.surfaceContainerHighest;
  Color get _thumbOn => disabled ? colorScheme.onSurface.withAlpha(97) : colorScheme.onPrimary;
  Color get _thumbOff => disabled ? colorScheme.onSurface.withAlpha(97) : colorScheme.outline;
  Color get _iconOn => disabled ? colorScheme.onSurface.withAlpha(97) : colorScheme.onPrimaryContainer;
  Color get _iconOff => disabled ? colorScheme.onSurface.withAlpha(97) : colorScheme.onSurfaceVariant;
  Color get _outlineOff => disabled ? colorScheme.onSurface.withAlpha(25) : colorScheme.outline;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress;
    final trackWidth = tokens.trackWidth;
    final trackHeight = tokens.trackHeight;
    final thumbSize = tokens.thumbSize;
    final thumbRadius = thumbSize / 2;
    final trackRadius = trackHeight / 2;

    // ── Track ──
    final trackPaint = Paint()..color = Color.lerp(_trackOff, _trackOn, t)!;
    final trackRect = RRect.fromRectAndRadius(
      Offset.zero & Size(trackWidth, trackHeight),
      Radius.circular(trackRadius),
    );
    canvas.drawRRect(trackRect, trackPaint);

    // ── Track outline (OFF only) ──
    if (t < 0.5) {
      final outlinePaint = Paint()
        ..color = Color.lerp(_outlineOff, Colors.transparent, t * 2)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = tokens.outlineWidth;
      canvas.drawRRect(trackRect, outlinePaint);
    }

    // ── Thumb position ──
    final thumbCenterXOff = 4.0 + thumbRadius; // 16dp
    final thumbCenterXOn = trackWidth - 4.0 - thumbRadius; // 36dp
    final thumbCenterX = lerpDouble(thumbCenterXOff, thumbCenterXOn, t)!;
    final thumbCenterY = trackHeight / 2;
    final thumbCenter = Offset(thumbCenterX, thumbCenterY);

    // ── Thumb ──
    final thumbPaint = Paint()..color = Color.lerp(_thumbOff, _thumbOn, t)!;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);

    // ── Icon (✓ or ×) — painted directly on canvas, no widget rebuild ──
    final iconPaint = Paint()
      ..color = Color.lerp(_iconOff, _iconOn, t)!
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final iconSize = tokens.iconSize;
    final half = iconSize / 2;

    if (value) {
      // ✓ check mark
      final path = Path()
        ..moveTo(thumbCenter.dx - half * 0.6, thumbCenter.dy)
        ..lineTo(thumbCenter.dx - half * 0.1, thumbCenter.dy + half * 0.5)
        ..lineTo(thumbCenter.dx + half * 0.6, thumbCenter.dy - half * 0.4);
      canvas.drawPath(path, iconPaint);
    } else {
      // × close mark
      canvas.drawLine(
        Offset(thumbCenter.dx - half * 0.45, thumbCenter.dy - half * 0.45),
        Offset(thumbCenter.dx + half * 0.45, thumbCenter.dy + half * 0.45),
        iconPaint,
      );
      canvas.drawLine(
        Offset(thumbCenter.dx + half * 0.45, thumbCenter.dy - half * 0.45),
        Offset(thumbCenter.dx - half * 0.45, thumbCenter.dy + half * 0.45),
        iconPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SwitchPainter old) => old.progress != progress;
}
