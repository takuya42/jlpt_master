import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AppBackgroundPainter(isDark: Theme.of(context).brightness == Brightness.dark),
      child: child,
    );
  }
}

class _AppBackgroundPainter extends CustomPainter {
  const _AppBackgroundPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ink = isDark ? const Color(0xFFE7EEF8) : const Color(0xFF172033);
    final baseTop = isDark ? const Color(0xFF151225) : const Color(0xFFFBFAFF);
    final baseMid = isDark ? const Color(0xFF0A2035) : const Color(0xFFF2F8FF);
    final baseBottom = isDark ? const Color(0xFF261B11) : const Color(0xFFFFF8ED);
    final blue = const Color(0xFF2F6BFF);
    final purple = const Color(0xFFA88BFF);
    final cyan = const Color(0xFF76D7FF);
    final orange = const Color(0xFFFFB45C);
    final white = Colors.white;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseTop, baseMid, baseBottom],
          stops: const [0.0, 0.54, 1.0],
        ).createShader(rect),
    );

    _drawAmbient(canvas, size, ink, blue, purple, cyan, orange, white);

    final globeRadius = size.width * 0.43;
    final globeCenter = Offset(size.width * 0.14, size.height * 0.84);
    final globeBounds = Rect.fromCircle(center: globeCenter, radius: globeRadius);
    final globeClip = Path()..addOval(globeBounds);

    canvas.drawCircle(
      globeCenter,
      globeRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.28, -0.36),
          radius: 1.02,
          colors: [
            white.withValues(alpha: isDark ? 0.135 : 0.160),
            cyan.withValues(alpha: isDark ? 0.070 : 0.080),
            blue.withValues(alpha: isDark ? 0.030 : 0.036),
            purple.withValues(alpha: isDark ? 0.018 : 0.022),
          ],
          stops: const [0.0, 0.36, 0.74, 1.0],
        ).createShader(globeBounds),
    );

    final halo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..color = cyan.withValues(alpha: isDark ? 0.055 : 0.045);
    canvas.drawCircle(globeCenter, globeRadius * 1.008, halo);
    canvas.drawCircle(
      globeCenter,
      globeRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..shader = SweepGradient(
          colors: [
            white.withValues(alpha: 0.16),
            cyan.withValues(alpha: 0.075),
            white.withValues(alpha: 0.03),
            white.withValues(alpha: 0.16),
          ],
        ).createShader(globeBounds),
    );

    canvas.save();
    canvas.clipPath(globeClip);
    _drawGlobeGrid(canvas, globeCenter, globeRadius, cyan, ink);
    _drawContinents(canvas, globeCenter, globeRadius, cyan);
    canvas.restore();

    _drawJapanAndRoutes(canvas, size, globeCenter, globeRadius, cyan, orange, white, ink);
    _drawLightParticles(canvas, size, cyan, white);
  }

  void _drawGlobeGrid(Canvas canvas, Offset c, double r, Color cyan, Color ink) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.62
      ..strokeCap = StrokeCap.round;
    for (final y in const [-0.62, -0.32, 0.0, 0.32, 0.62]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * y),
          width: r * 1.92,
          height: r * 2 * math.cos(y.abs() * math.pi / 2.08) * 0.18,
        ),
        paint..color = cyan.withValues(alpha: y == 0 ? 0.050 : 0.034),
      );
    }
    for (final x in const [-0.58, -0.28, 0.0, 0.28, 0.58]) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 2 * math.cos(x.abs() * math.pi / 2.16), height: r * 1.96),
        paint..color = ink.withValues(alpha: x == 0 ? 0.034 : 0.026),
      );
    }
  }

  void _drawContinents(Canvas canvas, Offset c, double r, Color cyan) {
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: isDark ? 0.060 : 0.070),
          const Color(0xFFBDEBFF).withValues(alpha: isDark ? 0.055 : 0.060),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..color = cyan.withValues(alpha: isDark ? 0.038 : 0.032);

    Path smooth(List<Offset> pts) {
      final path = Path()..moveTo(c.dx + pts.first.dx * r, c.dy + pts.first.dy * r);
      for (var i = 0; i < pts.length; i++) {
        final current = pts[i];
        final next = pts[(i + 1) % pts.length];
        final end = Offset(c.dx + (current.dx + next.dx) * r / 2, c.dy + (current.dy + next.dy) * r / 2);
        path.quadraticBezierTo(c.dx + current.dx * r, c.dy + current.dy * r, end.dx, end.dy);
      }
      return path..close();
    }

    final paths = [
      smooth(const [
        Offset(-0.08, -0.48), Offset(0.12, -0.63), Offset(0.34, -0.57), Offset(0.55, -0.46), Offset(0.66, -0.29), Offset(0.52, -0.16), Offset(0.30, -0.15), Offset(0.10, -0.25),
      ]),
      smooth(const [
        Offset(0.36, -0.13), Offset(0.58, -0.05), Offset(0.72, 0.10), Offset(0.62, 0.24), Offset(0.42, 0.18), Offset(0.32, 0.02),
      ]),
      smooth(const [
        Offset(0.61, 0.42), Offset(0.82, 0.40), Offset(0.89, 0.54), Offset(0.76, 0.65), Offset(0.55, 0.60), Offset(0.49, 0.49),
      ]),
    ];

    for (final path in paths) {
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
  }

  void _drawJapanAndRoutes(Canvas canvas, Size size, Offset c, double r, Color cyan, Color orange, Color white, Color ink) {
    final japan = Offset(c.dx + r * 0.58, c.dy - r * 0.28);
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(japan, r * 0.070, glow..color = cyan.withValues(alpha: 0.080));
    canvas.drawCircle(japan, r * 0.030, glow..color = white.withValues(alpha: 0.075));

    final islandPaint = Paint()..color = white.withValues(alpha: isDark ? 0.185 : 0.230);
    for (final p in [const Offset(-4.8, -8.5), const Offset(-1.0, -3.0), const Offset(3.2, 3.0), const Offset(5.8, 8.4)]) {
      canvas.drawOval(Rect.fromCenter(center: japan + p, width: 3.1, height: 7.2), islandPaint);
    }
    canvas.drawCircle(japan, 2.2, Paint()..color = orange.withValues(alpha: 0.30));
    canvas.drawCircle(japan, 1.15, Paint()..color = white.withValues(alpha: 0.45));

    final routes = [
      Path()..moveTo(japan.dx, japan.dy)..cubicTo(size.width * 0.50, size.height * 0.37, size.width * 0.73, size.height * 0.27, size.width * 0.96, size.height * 0.15),
      Path()..moveTo(japan.dx, japan.dy)..cubicTo(size.width * 0.55, size.height * 0.54, size.width * 0.78, size.height * 0.55, size.width * 1.02, size.height * 0.41),
    ];
    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.95
      ..strokeCap = StrokeCap.round
      ..color = white.withValues(alpha: isDark ? 0.105 : 0.088);
    for (final route in routes) {
      _drawDashedPath(canvas, route, routePaint, dash: 5.5, gap: 9.0);
    }
    _drawPlane(canvas, Offset(size.width * 0.70, size.height * 0.29), -0.44, ink.withValues(alpha: isDark ? 0.090 : 0.070));
    _drawPlane(canvas, Offset(size.width * 0.84, size.height * 0.52), -0.12, ink.withValues(alpha: isDark ? 0.075 : 0.058));
  }

  void _drawPlane(Canvas canvas, Offset p, double angle, Color color) {
    final path = Path()
      ..moveTo(8, 0)
      ..lineTo(-7, -3.7)
      ..lineTo(-4, 0)
      ..lineTo(-7, 3.7)
      ..close()
      ..moveTo(-2.3, 0)
      ..lineTo(-8.4, -6.6)
      ..lineTo(-6.2, 0)
      ..lineTo(-8.4, 6.6)
      ..close();
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(angle);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  void _drawAmbient(Canvas canvas, Size size, Color ink, Color blue, Color purple, Color cyan, Color orange, Color white) {
    final blur = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 44);
    canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.16), 104, blur..color = purple.withValues(alpha: isDark ? 0.080 : 0.070));
    canvas.drawCircle(Offset(size.width * 0.83, size.height * 0.24), 130, blur..color = orange.withValues(alpha: isDark ? 0.066 : 0.055));
    canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.74), 142, blur..color = blue.withValues(alpha: isDark ? 0.060 : 0.052));
    canvas.drawCircle(Offset(size.width * 0.30, size.height * 0.91), 104, blur..color = cyan.withValues(alpha: isDark ? 0.048 : 0.042));

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = white.withValues(alpha: isDark ? 0.095 : 0.085);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.25), 52, ring);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.25), 66, ring..color = white.withValues(alpha: isDark ? 0.040 : 0.034));
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.42), 30, ring..color = cyan.withValues(alpha: isDark ? 0.055 : 0.045));
  }

  void _drawLightParticles(Canvas canvas, Size size, Color cyan, Color white) {
    for (var i = 0; i < 24; i++) {
      final x = (math.sin(i * 12.989) * 43758.5453).abs() % 1 * size.width;
      final y = (math.sin(i * 78.233) * 24634.6345).abs() % 1 * size.height;
      final radius = i % 8 == 0 ? 1.35 : 0.75;
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = (i % 5 == 0 ? cyan : white).withValues(alpha: i % 8 == 0 ? 0.080 : 0.052));
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, {required double dash, required double gap}) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, math.min(distance + dash, metric.length)), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AppBackgroundPainter oldDelegate) => oldDelegate.isDark != isDark;
}
