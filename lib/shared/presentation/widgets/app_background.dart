import 'package:flutter/material.dart';

import '../../../app/theme/app_chrome_theme.dart';

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
    final chrome = Theme.of(context).extension<AppChromeTheme>()!;
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _AppBackgroundPainter(
            gradientColors: chrome.backgroundGradient,
            decorationColor: chrome.decorationColor,
            atmosphereOpacityFactor: worldMapOpacityFactor,
            ringOpacityFactor: globeOpacityFactor,
          ),
        ),
        child,
      ],
    );
  }
}

class _AppBackgroundPainter extends CustomPainter {
  const _AppBackgroundPainter({
    required this.gradientColors,
    required this.decorationColor,
    required this.atmosphereOpacityFactor,
    required this.ringOpacityFactor,
  });

  final double atmosphereOpacityFactor;
  final double ringOpacityFactor;

  final List<Color> gradientColors;
  final Color decorationColor;

  static const _blue = Color(0xFF4D9CFF);
  static const _purple = Color(0xFF9B6BFF);
  static const _orange = Color(0xFFFF9A45);

  double _atmosphereAlpha(double alpha) => alpha * atmosphereOpacityFactor;
  double _ringAlpha(double alpha) => alpha * ringOpacityFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
          stops: [0, .48, 1],
        ).createShader(rect),
    );

    _drawSoftGlows(canvas, size);
    _drawAtmosphericOrbs(canvas, size);
    _drawGlassRings(canvas, size);
    _drawFineCurves(canvas, size);
    _drawAirParticles(canvas, size);
  }

  void _drawSoftGlows(Canvas canvas, Size size) {
    _drawGlow(
      canvas,
      center: Offset(size.width * .22, size.height * .08),
      radius: size.shortestSide * .74,
      color: _blue.withValues(alpha: _atmosphereAlpha(.075)),
      blur: 150,
    );
    _drawGlow(
      canvas,
      center: Offset(size.width * 1.06, size.height * .20),
      radius: size.shortestSide * .62,
      color: _purple.withValues(alpha: _atmosphereAlpha(.070)),
      blur: 170,
    );
    _drawGlow(
      canvas,
      center: Offset(size.width * -.12, size.height * .78),
      radius: size.shortestSide * .56,
      color: _orange.withValues(alpha: _atmosphereAlpha(.050)),
      blur: 140,
    );
  }

  void _drawGlow(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double blur,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
        ..color = color,
    );
  }

  void _drawAtmosphericOrbs(Canvas canvas, Size size) {
    final specs = [
      _OrbSpec(
        Offset(size.width * .08, size.height * .28),
        size.shortestSide * .62,
        _blue,
        .045,
      ),
      _OrbSpec(
        Offset(size.width * .86, size.height * .62),
        size.shortestSide * .54,
        _purple,
        .040,
      ),
      _OrbSpec(
        Offset(size.width * .50, size.height * .44),
        size.shortestSide * .42,
        decorationColor,
        .024,
      ),
    ];

    for (final spec in specs) {
      final rect = Rect.fromCircle(center: spec.center, radius: spec.radius);
      canvas.drawCircle(
        spec.center,
        spec.radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              spec.color.withValues(alpha: _atmosphereAlpha(spec.alpha)),
              spec.color.withValues(alpha: _atmosphereAlpha(spec.alpha * .32)),
              spec.color.withValues(alpha: 0),
            ],
            stops: const [0, .48, 1],
          ).createShader(rect),
      );
    }
  }

  void _drawGlassRings(Canvas canvas, Size size) {
    _drawGlassRing(
      canvas,
      center: Offset(size.width * -.06, size.height * .88),
      radius: size.shortestSide * .34,
    );
    _drawGlassRing(
      canvas,
      center: Offset(size.width * 1.03, size.height * .10),
      radius: size.shortestSide * .28,
    );
    _drawGlassRing(
      canvas,
      center: Offset(size.width * .53, size.height * .48),
      radius: size.shortestSide * .25,
    );
  }

  void _drawGlassRing(
    Canvas canvas, {
    required Offset center,
    required double radius,
  }) {
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = SweepGradient(
          colors: [
            decorationColor.withValues(alpha: _ringAlpha(.012)),
            decorationColor.withValues(alpha: _ringAlpha(.050)),
            decorationColor.withValues(alpha: _ringAlpha(.018)),
            decorationColor.withValues(alpha: _ringAlpha(.050)),
            decorationColor.withValues(alpha: _ringAlpha(.012)),
          ],
          stops: const [0, .24, .52, .78, 1],
        ).createShader(bounds),
    );
    canvas.drawCircle(
      center,
      radius * .965,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .6
        ..color = decorationColor.withValues(alpha: _ringAlpha(.018)),
    );
  }

  void _drawFineCurves(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..strokeCap = StrokeCap.round
      ..color = decorationColor.withValues(alpha: _atmosphereAlpha(.055));

    final paths = [
      Path()
        ..moveTo(size.width * -.08, size.height * .34)
        ..cubicTo(
          size.width * .24,
          size.height * .20,
          size.width * .62,
          size.height * .24,
          size.width * 1.08,
          size.height * .08,
        ),
      Path()
        ..moveTo(size.width * .16, size.height * .88)
        ..cubicTo(
          size.width * .42,
          size.height * .66,
          size.width * .70,
          size.height * .68,
          size.width * 1.10,
          size.height * .44,
        ),
      Path()
        ..moveTo(size.width * -.10, size.height * .64)
        ..cubicTo(
          size.width * .18,
          size.height * .52,
          size.width * .48,
          size.height * .58,
          size.width * .74,
          size.height * .42,
        ),
    ];

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  void _drawAirParticles(Canvas canvas, Size size) {
    const particles = [
      Offset(.18, .22),
      Offset(.34, .72),
      Offset(.58, .18),
      Offset(.72, .56),
      Offset(.86, .32),
      Offset(.92, .78),
      Offset(.12, .60),
    ];

    for (var i = 0; i < particles.length; i++) {
      final unit = particles[i];
      final radius = i.isEven ? .9 : .65;
      canvas.drawCircle(
        Offset(unit.dx * size.width, unit.dy * size.height),
        radius,
        Paint()..color = decorationColor.withValues(alpha: _atmosphereAlpha(.070)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AppBackgroundPainter oldDelegate) =>
      oldDelegate.atmosphereOpacityFactor != atmosphereOpacityFactor ||
      oldDelegate.ringOpacityFactor != ringOpacityFactor ||
      oldDelegate.gradientColors != gradientColors ||
      oldDelegate.decorationColor != decorationColor;
}

class _OrbSpec {
  const _OrbSpec(this.center, this.radius, this.color, this.alpha);

  final Offset center;
  final double radius;
  final Color color;
  final double alpha;
}
