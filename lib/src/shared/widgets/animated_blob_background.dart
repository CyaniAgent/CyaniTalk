import 'dart:math';
import 'package:flutter/material.dart';
import '/src/core/theme/sauce_palette.dart';

class AnimatedBlobBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBlobBackground({super.key, required this.child});

  @override
  State<AnimatedBlobBackground> createState() =>
      _AnimatedBlobBackgroundState();
}

class _AnimatedBlobBackgroundState extends State<AnimatedBlobBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final s = size.shortestSide;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _TriangleShape(listenable: _controller, size: size, s: s),
            _QuadShape(listenable: _controller, size: size, s: s),
            _HexagonShape(listenable: _controller, size: size, s: s),
            _DiamondShape(listenable: _controller, size: size, s: s),
            Positioned.fill(child: widget.child),
          ],
        );
      },
    );
  }
}

/// Builds a rounded polygon path from vertices with a given corner radius.
Path _roundedPolygon(List<Offset> vertices, double radius) {
  if (vertices.length < 3 || radius <= 0) {
    final p = Path()..moveTo(vertices[0].dx, vertices[0].dy);
    for (int i = 1; i < vertices.length; i++) {
      p.lineTo(vertices[i].dx, vertices[i].dy);
    }
    p.close();
    return p;
  }

  final path = Path();
  final n = vertices.length;

  for (int i = 0; i < n; i++) {
    final prev = vertices[(i - 1 + n) % n];
    final curr = vertices[i];
    final next = vertices[(i + 1) % n];

    final d1 = (curr - prev);
    final d2 = (next - curr);
    final len1 = d1.distance;
    final len2 = d2.distance;
    if (len1 < 0.001 || len2 < 0.001) {
      path.lineTo(curr.dx, curr.dy);
      continue;
    }

    final u1 = d1 / len1;
    final u2 = d2 / len2;
    final r = min(radius, min(len1, len2) * 0.49);

    final pA = curr - u1 * r;
    final pB = curr + u2 * r;

    if (i == 0) {
      path.moveTo(pA.dx, pA.dy);
    } else {
      path.lineTo(pA.dx, pA.dy);
    }
    path.quadraticBezierTo(curr.dx, curr.dy, pB.dx, pB.dy);
  }
  path.close();
  return path;
}

// ─── Triangle: top-left of center, rotates ───────────────────────────
class _TriangleShape extends AnimatedWidget {
  final Size size;
  final double s;

  const _TriangleShape({
    required super.listenable,
    required this.size,
    required this.s,
  });

  AnimationController get _c => listenable as AnimationController;

  @override
  Widget build(BuildContext context) {
    final t = _c.value * 2 * pi;
    final cx = size.width * 0.35;
    final cy = size.height * 0.32;
    final r = s * 0.09;
    final rotation = t * 0.3;
    final base = Offset(cx, cy);

    final verts = [
      _rot(Offset(cx, cy - r), base, rotation),
      _rot(Offset(cx - r * 0.866, cy + r * 0.5), base, rotation),
      _rot(Offset(cx + r * 0.866, cy + r * 0.5), base, rotation),
    ];

    return Positioned.fill(
      child: CustomPaint(
        painter: _ShapePainter(
          vertices: verts,
          cornerRadius: r * 0.3,
          fillColor: SaucePalette.mikuGreen.withAlpha(25),
          strokeColor: SaucePalette.mikuGreen.withAlpha(40),
        ),
      ),
    );
  }

  Offset _rot(Offset p, Offset ctr, double a) {
    final dx = p.dx - ctr.dx;
    final dy = p.dy - ctr.dy;
    return Offset(
      ctr.dx + dx * cos(a) - dy * sin(a),
      ctr.dy + dx * sin(a) + dy * cos(a),
    );
  }
}

// ─── Irregular Quadrilateral: top-right, morphs + drifts ─────────────
class _QuadShape extends AnimatedWidget {
  final Size size;
  final double s;

  const _QuadShape({
    required super.listenable,
    required this.size,
    required this.s,
  });

  AnimationController get _c => listenable as AnimationController;

  @override
  Widget build(BuildContext context) {
    final t = _c.value * 2 * pi;
    final cx = size.width * 0.65;
    final cy = size.height * 0.35;
    final baseR = s * 0.085;
    final dx = sin(t * 0.4) * 10;
    final dy = cos(t * 0.55) * 8;
    final cx2 = cx + dx;
    final cy2 = cy + dy;

    final vOff = List.generate(4, (i) {
      final ph = i * pi / 2;
      return Offset(
        sin(t * 0.3 + ph) * baseR * 0.25,
        cos(t * 0.35 + ph * 1.2) * baseR * 0.25,
      );
    });

    final verts = [
      Offset(cx2 - baseR + vOff[0].dx, cy2 - baseR * 0.3 + vOff[0].dy),
      Offset(cx2 + baseR * 0.8 + vOff[1].dx, cy2 - baseR * 0.5 + vOff[1].dy),
      Offset(cx2 + baseR * 1.2 + vOff[2].dx, cy2 + baseR * 0.6 + vOff[2].dy),
      Offset(cx2 - baseR * 0.5 + vOff[3].dx, cy2 + baseR * 0.8 + vOff[3].dy),
    ];

    return Positioned.fill(
      child: CustomPaint(
        painter: _ShapePainter(
          vertices: verts,
          cornerRadius: baseR * 0.3,
          fillColor: const Color(0xFF4FC3F7).withAlpha(22),
          strokeColor: const Color(0xFF4FC3F7).withAlpha(35),
        ),
      ),
    );
  }
}

// ─── Hexagon: bottom-center, pulses + bobs ───────────────────────────
class _HexagonShape extends AnimatedWidget {
  final Size size;
  final double s;

  const _HexagonShape({
    required super.listenable,
    required this.size,
    required this.s,
  });

  AnimationController get _c => listenable as AnimationController;

  @override
  Widget build(BuildContext context) {
    final t = _c.value * 2 * pi;
    final cx = size.width * 0.5;
    final cy = size.height * 0.68;
    final baseR = s * 0.08;
    final scale = 0.85 + sin(t * 0.5) * 0.15;
    final r = baseR * scale;
    final bobY = sin(t * 0.7) * 8;

    final verts = List.generate(6, (i) {
      final angle = (i / 6) * 2 * pi - pi / 2;
      return Offset(cx + cos(angle) * r, cy + sin(angle) * r + bobY);
    });

    return Positioned.fill(
      child: CustomPaint(
        painter: _ShapePainter(
          vertices: verts,
          cornerRadius: r * 0.25,
          fillColor: const Color(0xFFCE93D8).withAlpha(20),
          strokeColor: const Color(0xFFCE93D8).withAlpha(32),
        ),
      ),
    );
  }
}

// ─── Diamond: bottom-right, drifts + fades ───────────────────────────
class _DiamondShape extends AnimatedWidget {
  final Size size;
  final double s;

  const _DiamondShape({
    required super.listenable,
    required this.size,
    required this.s,
  });

  AnimationController get _c => listenable as AnimationController;

  @override
  Widget build(BuildContext context) {
    final t = _c.value * 2 * pi;
    final cx = size.width * 0.72;
    final cy = size.height * 0.62;
    final r = s * 0.055;
    final driftX = sin(t * 0.25) * 10;
    final driftY = cos(t * 0.35) * 8;
    final opacity = (0.5 + sin(t * 0.6) * 0.5).clamp(0.15, 0.85);

    final verts = [
      Offset(cx + driftX, cy - r + driftY),
      Offset(cx + r + driftX, cy + driftY),
      Offset(cx + driftX, cy + r + driftY),
      Offset(cx - r + driftX, cy + driftY),
    ];

    return Positioned.fill(
      child: CustomPaint(
        painter: _ShapePainter(
          vertices: verts,
          cornerRadius: r * 0.3,
          fillColor: SaucePalette.mikuGreen.withAlpha((20 * opacity).round()),
          strokeColor: SaucePalette.mikuGreen.withAlpha((35 * opacity).round()),
        ),
      ),
    );
  }
}

// ─── Shared shape painter with rounded corners ───────────────────────
class _ShapePainter extends CustomPainter {
  final List<Offset> vertices;
  final double cornerRadius;
  final Color fillColor;
  final Color strokeColor;

  _ShapePainter({
    required this.vertices,
    this.cornerRadius = 0,
    required this.fillColor,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (vertices.length < 3) return;

    final path = _roundedPolygon(vertices, cornerRadius);

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(_ShapePainter old) =>
      old.vertices != vertices ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor;
}
