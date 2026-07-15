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
    final ink = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
    final baseTop = isDark ? const Color(0xFF141128) : const Color(0xFFF9F7FF);
    final baseMid = isDark ? const Color(0xFF0B1D32) : const Color(0xFFEFF7FF);
    final baseBottom = isDark ? const Color(0xFF24180B) : const Color(0xFFFFF8EE);
    final blue = const Color(0xFF2563EB);
    final purple = const Color(0xFF9F7AEA);
    final cyan = const Color(0xFF38BDF8);
    final orange = const Color(0xFFF59E0B);
    final white = Colors.white;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseTop, baseMid, baseBottom],
        ).createShader(rect),
    );

    _drawAmbient(canvas, size, ink, blue, purple, cyan, orange, white);

    final globeRadius = size.width * 0.45;
    final globeCenter = Offset(size.width * 0.18, size.height * 0.82);
    final globeBounds = Rect.fromCircle(center: globeCenter, radius: globeRadius);
    final globeClip = Path()..addOval(globeBounds);

    canvas.drawCircle(
      globeCenter,
      globeRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.34, -0.42),
          radius: 1.0,
          colors: [
            white.withValues(alpha: isDark ? 0.105 : 0.115),
            cyan.withValues(alpha: isDark ? 0.082 : 0.095),
            blue.withValues(alpha: isDark ? 0.042 : 0.052),
            const Color(0xFF0F172A).withValues(alpha: isDark ? 0.052 : 0.020),
          ],
          stops: const [0.0, 0.34, 0.72, 1.0],
        ).createShader(globeBounds),
    );

    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..color = white.withValues(alpha: isDark ? 0.13 : 0.10);
    canvas.drawCircle(globeCenter, globeRadius, outerRingPaint);
    canvas.drawCircle(globeCenter, globeRadius * 0.975, outerRingPaint..color = cyan.withValues(alpha: isDark ? 0.11 : 0.085));
    canvas.drawCircle(globeCenter, globeRadius * 1.055, outerRingPaint..color = white.withValues(alpha: isDark ? 0.075 : 0.058));

    canvas.save();
    canvas.clipPath(globeClip);
    _drawGlobeGrid(canvas, globeCenter, globeRadius, cyan, ink);
    _drawContinents(canvas, globeCenter, globeRadius, cyan);
    canvas.restore();

    _drawJapanAndRoutes(canvas, size, globeCenter, globeRadius, cyan, orange, white, ink);
    _drawSparkles(canvas, size, ink, cyan, white);
  }

  void _drawGlobeGrid(Canvas canvas, Offset c, double r, Color cyan, Color ink) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final y in const [-0.72, -0.48, -0.24, 0.0, 0.24, 0.48, 0.72]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(c.dx, c.dy + r * y), width: r * 2, height: r * 2 * math.cos(y.abs() * math.pi / 2.05) * 0.22),
        paint..color = cyan.withValues(alpha: y == 0 ? 0.090 : 0.060),
      );
    }
    for (final x in const [-0.76, -0.52, -0.26, 0.0, 0.26, 0.52, 0.76]) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 2 * math.cos(x.abs() * math.pi / 2.18), height: r * 2),
        paint..color = ink.withValues(alpha: x == 0 ? 0.052 : 0.040),
      );
    }
  }

  void _drawContinents(Canvas canvas, Offset c, double r, Color cyan) {
    final fill = Paint()..color = const Color(0xFFE0F2FE).withValues(alpha: isDark ? 0.090 : 0.082);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = cyan.withValues(alpha: isDark ? 0.078 : 0.062);

    Path blob(List<Offset> pts) {
      final path = Path()..moveTo(c.dx + pts.first.dx * r, c.dy + pts.first.dy * r);
      for (var i = 1; i < pts.length; i++) {
        final p = pts[i - 1];
        final n = pts[i];
        path.quadraticBezierTo(c.dx + p.dx * r, c.dy + p.dy * r, c.dx + n.dx * r, c.dy + n.dy * r);
      }
      return path..close();
    }

    final chinaAsia = blob(const [
      Offset(0.15, -0.55), Offset(0.34, -0.66), Offset(0.59, -0.55), Offset(0.72, -0.38), Offset(0.58, -0.23), Offset(0.44, -0.12), Offset(0.24, -0.16), Offset(0.10, -0.30),
    ]);
    final southeastAsia = blob(const [
      Offset(0.42, -0.14), Offset(0.62, -0.06), Offset(0.73, 0.10), Offset(0.62, 0.25), Offset(0.44, 0.16), Offset(0.34, 0.00),
    ]);
    final australia = blob(const [
      Offset(0.62, 0.42), Offset(0.82, 0.38), Offset(0.90, 0.53), Offset(0.77, 0.66), Offset(0.55, 0.60), Offset(0.48, 0.49),
    ]);
    final farAsia = blob(const [
      Offset(-0.08, -0.48), Offset(0.12, -0.62), Offset(0.28, -0.48), Offset(0.18, -0.28), Offset(-0.02, -0.22), Offset(-0.19, -0.34),
    ]);

    for (final path in [farAsia, chinaAsia, southeastAsia, australia]) {
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
  }

  void _drawJapanAndRoutes(Canvas canvas, Size size, Offset c, double r, Color cyan, Color orange, Color white, Color ink) {
    final japan = Offset(c.dx + r * 0.58, c.dy - r * 0.28);
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(japan, r * 0.078, glow..color = cyan.withValues(alpha: 0.105));
    canvas.drawCircle(japan, r * 0.040, glow..color = white.withValues(alpha: 0.095));

    final islandPaint = Paint()..color = white.withValues(alpha: 0.22);
    for (final p in [const Offset(-5, -10), const Offset(0, -4), const Offset(4, 3), const Offset(7, 10)]) {
      canvas.drawOval(Rect.fromCenter(center: japan + p, width: 4.4, height: 9.5), islandPaint);
    }
    canvas.drawCircle(japan, 6.0, Paint()..color = const Color(0xFFE0F2FE).withValues(alpha: 0.20));
    canvas.drawCircle(japan, 2.4, Paint()..color = orange.withValues(alpha: 0.38));

    final routes = [
      Path()..moveTo(japan.dx, japan.dy)..cubicTo(size.width * 0.48, size.height * 0.36, size.width * 0.72, size.height * 0.28, size.width * 0.95, size.height * 0.14),
      Path()..moveTo(japan.dx, japan.dy)..cubicTo(size.width * 0.56, size.height * 0.52, size.width * 0.78, size.height * 0.55, size.width * 1.03, size.height * 0.40),
      Path()..moveTo(japan.dx, japan.dy)..cubicTo(size.width * 0.36, size.height * 0.43, size.width * 0.18, size.height * 0.32, -24, size.height * 0.24),
      Path()..moveTo(japan.dx, japan.dy)..cubicTo(size.width * 0.44, size.height * 0.72, size.width * 0.68, size.height * 0.82, size.width * 0.98, size.height * 0.76),
    ];
    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round
      ..color = white.withValues(alpha: isDark ? 0.135 : 0.115);
    for (final route in routes) {
      _drawDashedPath(canvas, route, routePaint, dash: 8, gap: 8);
      _drawRouteLights(canvas, route, cyan, white);
    }
    _drawPlane(canvas, Offset(size.width * 0.68, size.height * 0.31), -0.48, ink.withValues(alpha: isDark ? 0.14 : 0.105));
    _drawPlane(canvas, Offset(size.width * 0.83, size.height * 0.52), -0.15, ink.withValues(alpha: isDark ? 0.11 : 0.085));
  }

  void _drawPlane(Canvas canvas, Offset p, double angle, Color color) {
    final path = Path()
      ..moveTo(15, 0)..lineTo(-12, -7)..lineTo(-6, 0)..lineTo(-12, 7)..close()
      ..moveTo(-4, 0)..lineTo(-15, -13)..lineTo(-11, 0)..lineTo(-15, 13)..close();
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(angle);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  void _drawAmbient(Canvas canvas, Size size, Color ink, Color blue, Color purple, Color cyan, Color orange, Color white) {
    final blur = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.18), 88, blur..color = purple.withValues(alpha: 0.085));
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.22), 112, blur..color = orange.withValues(alpha: 0.074));
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.76), 126, blur..color = blue.withValues(alpha: 0.064));
    canvas.drawCircle(Offset(size.width * 0.33, size.height * 0.90), 96, blur..color = cyan.withValues(alpha: 0.060));

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = white.withValues(alpha: isDark ? 0.14 : 0.12);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.25), 48, ring);
    canvas.drawCircle(Offset(size.width * 0.16, size.height * 0.40), 28, ring..color = cyan.withValues(alpha: 0.075));
    canvas.drawCircle(Offset(size.width * 0.73, size.height * 0.88), 34, ring..color = ink.withValues(alpha: 0.045));
  }

  void _drawRouteLights(Canvas canvas, Path path, Color cyan, Color white) {
    for (final metric in path.computeMetrics()) {
      for (final t in const [0.22, 0.46, 0.72]) {
        final tangent = metric.getTangentForOffset(metric.length * t);
        if (tangent == null) continue;
        canvas.drawCircle(tangent.position, 2.2, Paint()..color = (t == 0.46 ? white : cyan).withValues(alpha: 0.105));
      }
    }
  }

  void _drawSparkles(Canvas canvas, Size size, Color ink, Color cyan, Color white) {
    for (var i = 0; i < 58; i++) {
      final x = (math.sin(i * 12.989) * 43758.5453).abs() % 1 * size.width;
      final y = (math.sin(i * 78.233) * 24634.6345).abs() % 1 * size.height;
      final radius = i % 7 == 0 ? 1.8 : 1.0;
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = (i % 4 == 0 ? cyan : white).withValues(alpha: i % 7 == 0 ? 0.11 : 0.075));
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
