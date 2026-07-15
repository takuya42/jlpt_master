import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.worldMapOpacityFactor = 1, this.globeOpacityFactor = 1});

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
  const _AppBackgroundPainter({required this.worldMapOpacityFactor, required this.globeOpacityFactor});

  final double worldMapOpacityFactor;
  final double globeOpacityFactor;

  double _globeAlpha(double alpha) => alpha * globeOpacityFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const navy = Color(0xFF0B1220);
    const blueBlack = Color(0xFF13233F);
    const black = Color(0xFF080B12);
    const accent = Color(0xFF7C8CFF);
    const ice = Color(0xFFE8FAFF);
    const cyan = Color(0xFF9BE7FF);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navy, blueBlack, black],
          stops: [0.0, 0.50, 1.0],
        ).createShader(rect),
    );

    _drawQuietLight(canvas, size, accent, cyan);
    _drawWorldMap(canvas, size, ice.withValues(alpha: 0.068 * worldMapOpacityFactor));
    _drawGlobe(canvas, size, accent, cyan, ice);
  }

  void _drawQuietLight(Canvas canvas, Size size, Color accent, Color cyan) {
    final blur = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 54);
    canvas.drawCircle(Offset(size.width * .88, size.height * .16), 150, blur..color = accent.withValues(alpha: .055));
    canvas.drawCircle(Offset(size.width * .20, size.height * .86), 125, blur..color = cyan.withValues(alpha: .045));
  }

  void _drawWorldMap(Canvas canvas, Size size, Color color) {
    final mapRect = Rect.fromCenter(
      center: Offset(size.width * .52, size.height * .43),
      width: size.width * 1.18,
      height: size.height * .58,
    );
    final paint = Paint()..color = color;
    for (final continent in _continents) {
      canvas.drawPath(_scaledPath(continent, mapRect), paint);
    }
    final japan = Offset(mapRect.left + mapRect.width * .815, mapRect.top + mapRect.height * .425);
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(japan, 11, glow..color = const Color(0xFFBDF3FF).withValues(alpha: .18));
    canvas.drawCircle(japan, 3.2, Paint()..color = const Color(0xFFE8FAFF).withValues(alpha: .34));
    _drawRoutes(canvas, japan, size, const Color(0xFFE8FAFF).withValues(alpha: .16));
  }

  Path _scaledPath(List<Offset> points, Rect r) {
    final path = Path()..moveTo(r.left + points.first.dx * r.width, r.top + points.first.dy * r.height);
    for (var i = 1; i < points.length; i++) {
      final p = points[i];
      path.lineTo(r.left + p.dx * r.width, r.top + p.dy * r.height);
    }
    return path..close();
  }

  void _drawRoutes(Canvas canvas, Offset japan, Size size, Color color) {
    final routes = [
      Path()..moveTo(japan.dx, japan.dy)..cubicTo(size.width * .62, size.height * .30, size.width * .43, size.height * .27, size.width * .23, size.height * .35),
      Path()..moveTo(japan.dx, japan.dy)..cubicTo(size.width * .76, size.height * .26, size.width * .90, size.height * .23, size.width * .99, size.height * .16),
      Path()..moveTo(japan.dx, japan.dy)..cubicTo(size.width * .71, size.height * .54, size.width * .55, size.height * .59, size.width * .42, size.height * .70),
    ];
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..strokeCap = StrokeCap.round..color = color;
    for (final route in routes) {
      _drawDashedPath(canvas, route, paint, dash: 5, gap: 8);
    }
    _drawPlane(canvas, Offset(size.width * .43, size.height * .29), 2.86, color.withValues(alpha: .8));
    _drawPlane(canvas, Offset(size.width * .87, size.height * .23), -.38, color.withValues(alpha: .75));
    _drawPlane(canvas, Offset(size.width * .57, size.height * .59), 2.45, color.withValues(alpha: .65));
  }

  void _drawGlobe(Canvas canvas, Size size, Color accent, Color cyan, Color ice) {
    final r = math.min(size.width, size.height) * .24;
    final c = Offset(size.width * .16, size.height * .88);
    final bounds = Rect.fromCircle(center: c, radius: r);
    final clip = Path()..addOval(bounds);
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(c, r * 1.04, glow..color = cyan.withValues(alpha: _globeAlpha(.10)));
    canvas.drawCircle(c, r, Paint()..shader = RadialGradient(center: const Alignment(-.35, -.45), colors: [Colors.white.withValues(alpha: _globeAlpha(.14)), cyan.withValues(alpha: _globeAlpha(.075)), accent.withValues(alpha: _globeAlpha(.032)), Colors.white.withValues(alpha: _globeAlpha(.018))], stops: const [.0, .36, .74, 1]).createShader(bounds));
    canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = ice.withValues(alpha: _globeAlpha(.18)));
    canvas.save(); canvas.clipPath(clip);
    final grid = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = ice.withValues(alpha: _globeAlpha(.12));
    for (final y in const [-.62, -.32, 0, .32, .62]) { canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * y), width: r * 1.88, height: r * .24 * math.cos(y.abs())), grid); }
    for (final x in const [-.58, -.28, 0, .28, .58]) { canvas.drawOval(Rect.fromCenter(center: c, width: r * 2 * math.cos(x.abs() * math.pi / 2.1), height: r * 1.95), grid); }
    final land = Paint()..color = ice.withValues(alpha: _globeAlpha(.08));
    canvas.drawPath(_globeLand(c, r, const [Offset(-.75,-.22),Offset(-.55,-.45),Offset(-.22,-.52),Offset(-.05,-.34),Offset(-.18,-.05),Offset(-.48,.08)]), land);
    canvas.drawPath(_globeLand(c, r, const [Offset(.05,-.45),Offset(.50,-.48),Offset(.78,-.20),Offset(.52,.05),Offset(.18,.00)]), land);
    canvas.drawPath(_globeLand(c, r, const [Offset(.40,.16),Offset(.78,.20),Offset(.72,.50),Offset(.44,.56),Offset(.28,.35)]), land);
    canvas.restore();
  }

  Path _globeLand(Offset c, double r, List<Offset> pts) => _scaledPath(pts.map((p) => Offset((p.dx + 1) / 2, (p.dy + 1) / 2)).toList(), Rect.fromCircle(center: c, radius: r));

  void _drawPlane(Canvas canvas, Offset p, double angle, Color color) { final path = Path()..moveTo(8,0)..lineTo(-7,-3.7)..lineTo(-4,0)..lineTo(-7,3.7)..close(); canvas.save(); canvas.translate(p.dx,p.dy); canvas.rotate(angle); canvas.drawPath(path, Paint()..color=color); canvas.restore(); }
  void _drawDashedPath(Canvas canvas, Path path, Paint paint, {required double dash, required double gap}) { for (final metric in path.computeMetrics()) { var d = 0.0; while (d < metric.length) { canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), paint); d += dash + gap; } } }

  @override
  bool shouldRepaint(covariant _AppBackgroundPainter oldDelegate) => oldDelegate.worldMapOpacityFactor != worldMapOpacityFactor || oldDelegate.globeOpacityFactor != globeOpacityFactor;
}

const _continents = <List<Offset>>[
  [Offset(.06,.34),Offset(.10,.23),Offset(.18,.18),Offset(.28,.19),Offset(.35,.27),Offset(.33,.36),Offset(.27,.39),Offset(.23,.48),Offset(.16,.47),Offset(.12,.40)],
  [Offset(.25,.50),Offset(.32,.54),Offset(.35,.65),Offset(.32,.82),Offset(.27,.90),Offset(.23,.76),Offset(.20,.63)],
  [Offset(.43,.23),Offset(.53,.18),Offset(.62,.21),Offset(.65,.30),Offset(.60,.38),Offset(.52,.38),Offset(.48,.46),Offset(.42,.40)],
  [Offset(.54,.43),Offset(.62,.46),Offset(.67,.58),Offset(.64,.72),Offset(.57,.76),Offset(.52,.63)],
  [Offset(.65,.24),Offset(.77,.20),Offset(.91,.27),Offset(.96,.39),Offset(.90,.49),Offset(.78,.45),Offset(.72,.37),Offset(.63,.36)],
  [Offset(.76,.55),Offset(.84,.57),Offset(.88,.66),Offset(.85,.75),Offset(.76,.72),Offset(.72,.63)],
  [Offset(.88,.72),Offset(.96,.73),Offset(.99,.80),Offset(.94,.87),Offset(.86,.84)],
];
