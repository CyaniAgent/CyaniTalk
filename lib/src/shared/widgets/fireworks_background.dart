import 'dart:math';
import 'package:flutter/material.dart';

class FireworksBackground extends StatefulWidget {
  final Widget child;

  const FireworksBackground({super.key, required this.child});

  @override
  State<FireworksBackground> createState() => _FireworksBackgroundState();
}

class _FireworksBackgroundState extends State<FireworksBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _rockets = <_Rocket>[];
  final _bursts = <_Burst>[];
  final _rng = Random(42);
  double _prevRaw = 0;
  double _sinceLastLaunch = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _sinceLastLaunch = 2;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final raw = _controller.value;
        double dt = raw - _prevRaw;
        if (dt < 0) dt += 1;
        _prevRaw = raw;
        _tick(dt * 30);
        return Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: ClipRect(
                  child: CustomPaint(
                    painter: _FireworksPainter(
                      rockets: _rockets,
                      bursts: _bursts,
                    ),
                  ),
                ),
              ),
            ),
            ?child,
          ],
        );
      },
      child: widget.child,
    );
  }

  void _tick(double dt) {
    for (int i = _rockets.length - 1; i >= 0; i--) {
      final r = _rockets[i];
      r.tick(dt);

      if (r.position.dy <= r.targetY && !r.exploded) {
        r.exploded = true;
        _burst(r.position, r.color);
      }

      if (r.dead) _rockets.removeAt(i);
    }

    for (int i = _bursts.length - 1; i >= 0; i--) {
      _bursts[i].tick(dt);
      if (_bursts[i].dead) _bursts.removeAt(i);
    }

    _sinceLastLaunch += dt;
    if (_sinceLastLaunch > 0.8 + _rng.nextDouble() * 1.5) {
      _sinceLastLaunch = 0;
      _launchRocket();
    }
  }

  void _launchRocket() {
    final scheme = Theme.of(context).colorScheme;
    _rockets.add(_Rocket(rng: _rng, colors: _themeColors(scheme)));
  }

  void _burst(Offset center, Color baseColor) {
    _bursts.add(_Burst(center: center, baseColor: baseColor, rng: _rng));
  }
}

// ─── Theme-derived firework palette ──────────────────────────────────
List<Color> _themeColors(ColorScheme s) => [
      s.primary,
      s.secondary,
      s.tertiary,
      HSLColor.fromColor(s.primary).withHue((HSLColor.fromColor(s.primary).hue + 30) % 360).toColor(),
      HSLColor.fromColor(s.secondary).withHue((HSLColor.fromColor(s.secondary).hue + 45) % 360).toColor(),
      HSLColor.fromColor(s.tertiary).withHue((HSLColor.fromColor(s.tertiary).hue + 60) % 360).toColor(),
      s.error,
    ];

// ─── Rocket ─────────────────────────────────────────────────────────
class _Rocket {
  Offset position;
  final double targetY;
  final Color color;
  final double speed;
  double life;
  bool exploded = false;
  final List<Offset> trail;

  _Rocket({required Random rng, required List<Color> colors})
      : position = Offset(
          0.15 + rng.nextDouble() * 0.7,
          0.95 + rng.nextDouble() * 0.05,
        ),
        targetY = 0.1 + rng.nextDouble() * 0.35,
        color = colors[rng.nextInt(colors.length)],
        speed = -0.006 - rng.nextDouble() * 0.003,
        life = 5.0,
        trail = [];

  bool get dead => life <= 0 || (!exploded && position.dy > 1.1);

  void tick(double dt) {
    trail.add(position);
    if (trail.length > 8) trail.removeAt(0);

    position = Offset(position.dx, position.dy + speed * dt * 60);
    life -= dt;
  }
}

// ─── Burst ──────────────────────────────────────────────────────────
class _Burst {
  final List<_Spark> sparks = [];
  final Offset center;
  final Color baseColor;
  final Random rng;
  double ringRadius = 0;
  double ringLife = 2.0;

  _Burst({
    required this.center,
    required this.baseColor,
    required this.rng,
  }) {
    _explode();
  }

  bool get dead => sparks.every((s) => s.dead) && ringLife <= 0;

  void tick(double dt) {
    ringRadius += dt * 0.12;
    ringLife -= dt;
    for (final s in sparks) {
      s.tick(dt);
    }
  }

  void _explode() {
    final baseHue = rng.nextDouble() * 360;
    const rayCount = 8;

    for (int ring = 0; ring < 3; ring++) {
      final offset = ring * pi / rayCount;
      final speedBase = 0.025 - ring * 0.005;
      final sparksPerRay = 6 - ring;

      for (int i = 0; i < rayCount; i++) {
        final baseAngle = (i / rayCount) * 2 * pi + offset;

        for (int j = 0; j < sparksPerRay; j++) {
          final angle = baseAngle + (rng.nextDouble() - 0.5) * 0.15;
          final speed = (speedBase + rng.nextDouble() * 0.008);
          final hue = (baseHue + rng.nextDouble() * 50) % 360;
          final size = 2.0 + rng.nextDouble() * 3.0;

          final sparkColor = Color.lerp(
            baseColor,
            HSLColor.fromAHSL(1, hue, 0.85, 0.55).toColor(),
            rng.nextDouble() * 0.6,
          )!;

          sparks.add(_Spark(
            x: center.dx,
            y: center.dy,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed,
            size: size,
            color: sparkColor,
            maxLife: 1.2 + rng.nextDouble() * 1.8,
          ));
        }
      }
    }

    for (int i = 0; i < 15; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 0.015 + rng.nextDouble() * 0.015;
      final hue = (baseHue + rng.nextDouble() * 70) % 360;
      final sparkColor = Color.lerp(
        baseColor,
        HSLColor.fromAHSL(1, hue, 0.85, 0.55).toColor(),
        rng.nextDouble() * 0.6,
      )!;
      sparks.add(_Spark(
        x: center.dx,
        y: center.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 2.0 + rng.nextDouble() * 2.5,
        color: sparkColor,
        maxLife: 1.5 + rng.nextDouble() * 1.5,
      ));
    }
  }
}

// ─── Spark ──────────────────────────────────────────────────────────
class _Spark {
  double x, y, vx, vy, size, life, maxLife;
  final Color color;
  final List<Offset> trail;

  _Spark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.maxLife,
  })  : life = maxLife,
        trail = [];

  bool get dead => life <= 0;

  void tick(double dt) {
    trail.add(Offset(x, y));
    if (trail.length > 6) trail.removeAt(0);

    x += vx * dt * 60;
    y += vy * dt * 60;
    vy += 0.0008 * dt * 60;
    vx *= 0.96;
    vy *= 0.96;
    life -= dt;
  }
}

// ─── Painter ────────────────────────────────────────────────────────
class _FireworksPainter extends CustomPainter {
  final List<_Rocket> rockets;
  final List<_Burst> bursts;

  _FireworksPainter({required this.rockets, required this.bursts});

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in rockets) {
      if (r.exploded) continue;
      _drawRocket(canvas, size, r);
    }

    for (final b in bursts) {
      _drawRing(canvas, size, b);
      for (final s in b.sparks) {
        _drawSpark(canvas, size, s);
      }
    }
  }

  void _drawRocket(Canvas canvas, Size size, _Rocket r) {
    final sx = r.position.dx * size.width;
    final sy = r.position.dy * size.height;

    // Trail
    for (int i = 0; i < r.trail.length; i++) {
      final t = r.trail[i];
      final alpha = (i / r.trail.length * 120).round().clamp(0, 120);
      canvas.drawCircle(
        Offset(t.dx * size.width, t.dy * size.height),
        1.5,
        Paint()..color = r.color.withAlpha(alpha),
      );
    }

    // Outer glow
    canvas.drawCircle(
      Offset(sx, sy),
      6,
      Paint()
        ..color = r.color.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Core
    canvas.drawCircle(
      Offset(sx, sy),
      2.5,
      Paint()..color = Colors.white,
    );

    // Inner colored glow
    canvas.drawCircle(
      Offset(sx, sy),
      3.5,
      Paint()..color = r.color.withAlpha(200),
    );
  }

  void _drawRing(Canvas canvas, Size size, _Burst b) {
    if (b.ringLife <= 0) return;
    final alpha = (b.ringLife / 2.0 * 80).round().clamp(0, 80);
    final cx = b.center.dx * size.width;
    final cy = b.center.dy * size.height;
    final r = b.ringRadius * size.shortestSide;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withAlpha(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.7,
      Paint()
        ..color = b.baseColor.withAlpha((alpha * 0.5).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawSpark(Canvas canvas, Size size, _Spark s) {
    final progress = 1 - s.life / s.maxLife;
    final opacity = (1 - progress) * (1 - progress * 0.4);
    final alpha = (opacity * 255).round().clamp(0, 255);
    final sx = s.x * size.width;
    final sy = s.y * size.height;

    // Trail
    for (int i = 0; i < s.trail.length; i++) {
      final t = s.trail[i];
      final ta = (i / s.trail.length * alpha * 0.4).round().clamp(0, alpha ~/ 2);
      canvas.drawCircle(
        Offset(t.dx * size.width, t.dy * size.height),
        s.size * 0.4,
        Paint()..color = s.color.withAlpha(ta),
      );
    }

    // Glow
    canvas.drawCircle(
      Offset(sx, sy),
      s.size * 2.5,
      Paint()
        ..color = s.color.withAlpha((alpha * 0.25).round())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Core
    canvas.drawCircle(
      Offset(sx, sy),
      s.size * (0.5 + (1 - progress) * 0.5),
      Paint()..color = s.color.withAlpha(alpha),
    );
  }

  @override
  bool shouldRepaint(_FireworksPainter old) => true;
}
