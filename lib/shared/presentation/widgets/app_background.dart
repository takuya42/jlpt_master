import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.worldMapOpacityFactor = 1,
    this.globeOpacityFactor = 1,
  });

  final Widget child;
  final double worldMapOpacityFactor;
  final double globeOpacityFactor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _AppBackgroundPainter(
            worldMapOpacityFactor: worldMapOpacityFactor,
            globeOpacityFactor: globeOpacityFactor,
          ),
        ),
        child,
      ],
    );
  }
}

class _AppBackgroundPainter extends CustomPainter {
  const _AppBackgroundPainter({
    required this.worldMapOpacityFactor,
    required this.globeOpacityFactor,
  });

  final double worldMapOpacityFactor;
  final double globeOpacityFactor;

  static const _top = Color(0xFF08111F);
  static const _middle = Color(0xFF10203B);
  static const _bottom = Color(0xFF050A14);
  static const _accent = Color(0xFF7C8CFF);
  static const _ice = Color(0xFFFFFFFF);

  double _globeAlpha(double alpha) => alpha * globeOpacityFactor;
  double _mapAlpha(double alpha) => alpha * worldMapOpacityFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_top, _middle, _bottom],
          stops: [0, .48, 1],
        ).createShader(rect),
    );

    _drawWorldMap(canvas, size);
    _drawJapanGlow(canvas, size);
    _drawSingleRoute(canvas, size);
    _drawGlassGlobe(canvas, size);
  }

  void _drawWorldMap(Canvas canvas, Size size) {
    final mapRect = Rect.fromCenter(
      center: Offset(size.width * .52, size.height * .40),
      width: size.width * 1.08,
      height: size.height * .46,
    );
    final paint = Paint()..color = _ice.withValues(alpha: _mapAlpha(.04));

    for (final continent in _continentBuilders) {
      canvas.drawPath(continent(mapRect), paint);
    }
  }

  void _drawJapanGlow(Canvas canvas, Size size) {
    final japan = _japanOffset(size);
    canvas.drawCircle(
      japan,
      28,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
        ..color = _accent.withValues(alpha: _mapAlpha(.22)),
    );
    canvas.drawCircle(
      japan,
      2.4,
      Paint()..color = const Color(0xFFE8FAFF).withValues(alpha: _mapAlpha(.42)),
    );
  }

  Offset _japanOffset(Size size) {
    final mapRect = Rect.fromCenter(
      center: Offset(size.width * .52, size.height * .40),
      width: size.width * 1.08,
      height: size.height * .46,
    );
    return Offset(mapRect.left + mapRect.width * .82, mapRect.top + mapRect.height * .42);
  }

  void _drawSingleRoute(Canvas canvas, Size size) {
    final japan = _japanOffset(size);
    final globeCenter = _globeCenter(size);
    final route = Path()
      ..moveTo(japan.dx, japan.dy)
      ..cubicTo(
        size.width * .66,
        size.height * .54,
        size.width * .34,
        size.height * .66,
        globeCenter.dx + _globeRadius(size) * .28,
        globeCenter.dy - _globeRadius(size) * .18,
      );

    _drawDashedPath(
      canvas,
      route,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..strokeCap = StrokeCap.round
        ..color = _ice.withValues(alpha: .15),
      dash: 3.5,
      gap: 7,
    );
    _drawPlane(
      canvas,
      Offset(size.width * .55, size.height * .56),
      2.34,
      _ice.withValues(alpha: .10),
    );
  }

  void _drawGlassGlobe(Canvas canvas, Size size) {
    final r = _globeRadius(size);
    final c = _globeCenter(size);
    final bounds = Rect.fromCircle(center: c, radius: r);
    final clip = Path()..addOval(bounds);

    canvas.drawCircle(
      c,
      r * 1.08,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
        ..color = _ice.withValues(alpha: _globeAlpha(.035)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.45, -.55),
          colors: [
            _ice.withValues(alpha: _globeAlpha(.10)),
            _accent.withValues(alpha: _globeAlpha(.045)),
            _ice.withValues(alpha: _globeAlpha(.012)),
          ],
          stops: const [0, .48, 1],
        ).createShader(bounds),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8
        ..color = _ice.withValues(alpha: _globeAlpha(.20)),
    );

    canvas.save();
    canvas.clipPath(clip);
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .45
      ..color = _ice.withValues(alpha: _globeAlpha(.16));
    for (final y in const [-.60, -.32, 0, .32, .60]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + r * y),
          width: r * 1.82,
          height: r * .22 * math.cos(y.abs()),
        ),
        grid,
      );
    }
    for (final x in const [-.58, -.28, 0, .28, .58]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: c,
          width: r * 2 * math.cos(x.abs() * math.pi / 2.1),
          height: r * 1.94,
        ),
        grid,
      );
    }
    canvas.restore();
  }

  Offset _globeCenter(Size size) => Offset(size.width * .15, size.height * .89);

  double _globeRadius(Size size) => math.min(size.width, size.height) * .276;

  void _drawPlane(Canvas canvas, Offset p, double angle, Color color) {
    final path = Path()
      ..moveTo(7, 0)
      ..lineTo(-6, -3)
      ..lineTo(-3.6, 0)
      ..lineTo(-6, 3)
      ..close();
    canvas
      ..save()
      ..translate(p.dx, p.dy)
      ..rotate(angle)
      ..drawPath(path, Paint()..color = color)
      ..restore();
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, math.min(distance + dash, metric.length)),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AppBackgroundPainter oldDelegate) =>
      oldDelegate.worldMapOpacityFactor != worldMapOpacityFactor ||
      oldDelegate.globeOpacityFactor != globeOpacityFactor;
}

typedef _ContinentBuilder = Path Function(Rect rect);

final List<_ContinentBuilder> _continentBuilders = [
  _northAmerica,
  _southAmerica,
  _europe,
  _africa,
  _asia,
  _australia,
];

Offset _p(Rect r, double x, double y) => Offset(r.left + r.width * x, r.top + r.height * y);

void _move(Path path, Rect r, double x, double y) => path.moveTo(_p(r, x, y).dx, _p(r, x, y).dy);

void _curve(
  Path path,
  Rect r,
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
) {
  path.cubicTo(
    _p(r, x1, y1).dx,
    _p(r, x1, y1).dy,
    _p(r, x2, y2).dx,
    _p(r, x2, y2).dy,
    _p(r, x3, y3).dx,
    _p(r, x3, y3).dy,
  );
}

Path _northAmerica(Rect r) {
  final path = Path();
  _move(path, r, .06, .30);
  _curve(path, r, .10, .16, .23, .12, .32, .20);
  _curve(path, r, .39, .27, .36, .38, .27, .40);
  _curve(path, r, .22, .42, .20, .53, .13, .47);
  _curve(path, r, .07, .42, .03, .37, .06, .30);
  return path..close();
}

Path _southAmerica(Rect r) {
  final path = Path();
  _move(path, r, .26, .50);
  _curve(path, r, .34, .53, .37, .63, .34, .75);
  _curve(path, r, .32, .85, .26, .94, .23, .84);
  _curve(path, r, .20, .73, .19, .61, .26, .50);
  return path..close();
}

Path _europe(Rect r) {
  final path = Path();
  _move(path, r, .43, .25);
  _curve(path, r, .50, .18, .61, .20, .64, .30);
  _curve(path, r, .60, .39, .50, .41, .43, .35);
  _curve(path, r, .39, .31, .40, .28, .43, .25);
  return path..close();
}

Path _africa(Rect r) {
  final path = Path();
  _move(path, r, .52, .38);
  _curve(path, r, .62, .39, .69, .52, .66, .66);
  _curve(path, r, .64, .77, .56, .80, .52, .69);
  _curve(path, r, .47, .56, .45, .44, .52, .38);
  return path..close();
}

Path _asia(Rect r) {
  final path = Path();
  _move(path, r, .63, .25);
  _curve(path, r, .72, .15, .91, .22, .97, .36);
  _curve(path, r, .92, .48, .82, .52, .74, .45);
  _curve(path, r, .68, .40, .60, .38, .63, .25);
  return path..close();
}

Path _australia(Rect r) {
  final path = Path();
  _move(path, r, .82, .66);
  _curve(path, r, .89, .62, .98, .69, .95, .78);
  _curve(path, r, .91, .86, .80, .83, .76, .74);
  _curve(path, r, .76, .70, .79, .68, .82, .66);
  return path..close();
}
