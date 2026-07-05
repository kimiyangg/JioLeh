import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

// Note: The loading animations of this page is designed and implemented by AI

class BrandLoadingAnimation extends StatefulWidget {
  const BrandLoadingAnimation({
    super.key, 
    this.width = 170, 
    this.onIntroComplete
  }) : compact = false;

  const BrandLoadingAnimation.compact({
    super.key,
    this.width = 40,
    this.onIntroComplete,
  }) : compact = true;

  final double width;
  final bool compact;
  final VoidCallback? onIntroComplete;

  @override
  State<BrandLoadingAnimation> createState() => _BrandLoadingAnimationState();
}

class _BrandLoadingAnimationState extends State<BrandLoadingAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _intro = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.compact ? 450 : 1500),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _idle.repeat(reverse: true);
          widget.onIntroComplete?.call();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = widget.compact ? _BrandPainter.pinViewBox : _BrandPainter.viewBox;
    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _idle]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.width, widget.width * box.height / box.width),
          painter: _BrandPainter(
            intro: _intro.value,
            idle: _idle.value,
            compact: widget.compact,
          ),
        );
      },
    );
  }
}

class _BrandPainter extends CustomPainter {
  _BrandPainter({required this.intro, required this.idle, required this.compact});

  final double intro;
  final double idle;
  final bool compact;

  static const viewBox = Rect.fromLTWH(190, 110, 425, 560);
  static const pinViewBox = Rect.fromLTWH(268, 112, 281, 399);
  static const _pinCenter = Offset(408.5, 311.5);

  static double _local(double value, double start, double end) {
    if (value <= start) return 0;
    if (value >= end) return 1;
    return (value - start) / (end - start);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = compact ? pinViewBox : viewBox;
    final scale = size.width / box.width;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(-box.left, -box.top);

    final breathe = 1 + 0.025 * idle;
    canvas.save();
    canvas.translate(_pinCenter.dx, _pinCenter.dy);
    canvas.scale(breathe);
    canvas.translate(-_pinCenter.dx, -_pinCenter.dy);
    _paintPin(canvas);
    canvas.restore();

    if (!compact) _paintWordmark(canvas);
    canvas.restore();
  }

  void _paintPin(Canvas canvas) {
    if (compact) {
      final popT = Curves.elasticOut.transform(_local(intro, 0.0, 1.0));
      final fillT = _local(intro, 0.0, 0.4);
      if (fillT > 0) {
        canvas.save();
        canvas.translate(_pinCenter.dx, _pinCenter.dy);
        canvas.scale(0.8 + 0.2 * popT);
        canvas.translate(-_pinCenter.dx, -_pinCenter.dy);
        canvas.drawPath(
          _pinFill,
          Paint()..color = LogoColors.forestLogo.withValues(alpha: fillT),
        );
        canvas.restore();
      }
      return;
    }

    final traceT = Curves.easeOut.transform(_local(intro, 0.0, 0.5));
    final popT = Curves.elasticOut.transform(_local(intro, 0.42, 0.85));
    final fillT = _local(intro, 0.42, 0.6);

    if (traceT > 0 && fillT < 1) {
      final metric = _pinOutline.computeMetrics().first;
      final partial = metric.extractPath(0, metric.length * traceT);
      canvas.drawPath(
        partial,
        Paint()
          ..color = LogoColors.forestLogo
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }

    if (fillT > 0) {
      canvas.save();
      canvas.translate(_pinCenter.dx, _pinCenter.dy);
      canvas.scale(0.8 + 0.2 * popT);
      canvas.translate(-_pinCenter.dx, -_pinCenter.dy);
      canvas.drawPath(
        _pinFill,
        Paint()..color = LogoColors.forestLogo.withValues(alpha: fillT),
      );
      canvas.restore();
    }
  }

  static const _letterX = [205.49138, 265.749453, 305.20157, 380.362181, 452.715052, 525.643905];
  static const _letterBaselineY = 656.234383;

  void _paintWordmark(Canvas canvas) {
    for (var i = 0; i < _letters.length; i++) {
      final start = 0.55 + i * 0.06;
      final end = (start + 0.28).clamp(0.0, 1.0);
      final t = Curves.easeOutCubic.transform(_local(intro, start, end));
      if (t <= 0) continue;
      canvas.save();
      canvas.translate(_letterX[i], _letterBaselineY + (1 - t) * 24);
      canvas.drawPath(
        _letters[i],
        Paint()..color = LogoColors.forestLogo.withValues(alpha: t),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BrandPainter oldDelegate) =>
      oldDelegate.intro != intro ||
      oldDelegate.idle != idle ||
      oldDelegate.compact != compact;

  static final Path _pinOutline = Path()
    ..moveTo(413.516, 463.575)
    ..cubicTo(416.009, 455.782, 424.869, 438.748, 432.686, 426.715)
    ..cubicTo(441.696, 412.848, 455.307, 395.159, 480.099, 365.102)
    ..cubicTo(512.324, 326.030, 524.621, 306.754, 532.359, 283.186)
    ..cubicTo(539.472, 261.518, 539.111, 232.366, 531.450, 209.842)
    ..cubicTo(519.235, 173.927, 491.264, 145.853, 455.554, 133.666)
    ..cubicTo(437.848, 127.622, 426.715, 126.166, 404.325, 126.966)
    ..cubicTo(384.143, 127.688, 372.040, 130.347, 355.492, 137.697)
    ..cubicTo(310.556, 157.654, 281.789, 205.256, 284.670, 254.887)
    ..cubicTo(286.610, 288.295, 298.960, 312.449, 339.172, 361.474)
    ..cubicTo(365.082, 393.062, 381.369, 414.269, 390.542, 428.359)
    ..cubicTo(398.032, 439.866, 407.277, 458.224, 408.935, 464.880)
    ..cubicTo(410.160, 469.805, 411.660, 469.377, 413.516, 463.575)
    ..close();

  static final Path _pinFill = Path()
    ..fillType = PathFillType.evenOdd
    ..moveTo(420.083, 495.970)
    ..cubicTo(428.392, 487.661, 422.259, 473.688, 410.303, 473.688)
    ..cubicTo(408.473, 473.688, 405.071, 475.389, 402.744, 477.469)
    ..cubicTo(399.242, 480.598, 398.512, 482.195, 398.512, 486.736)
    ..cubicTo(398.512, 491.277, 399.242, 492.874, 402.744, 496.003)
    ..cubicTo(408.537, 501.179, 414.886, 501.167, 420.083, 495.970)
    ..close()
    ..moveTo(413.516, 463.575)
    ..cubicTo(416.009, 455.782, 424.869, 438.748, 432.686, 426.715)
    ..cubicTo(441.696, 412.848, 455.307, 395.159, 480.099, 365.102)
    ..cubicTo(512.324, 326.030, 524.621, 306.754, 532.359, 283.186)
    ..cubicTo(539.472, 261.518, 539.111, 232.366, 531.450, 209.842)
    ..cubicTo(519.235, 173.927, 491.264, 145.853, 455.554, 133.666)
    ..cubicTo(437.848, 127.622, 426.715, 126.166, 404.325, 126.966)
    ..cubicTo(384.143, 127.688, 372.040, 130.347, 355.492, 137.697)
    ..cubicTo(310.556, 157.654, 281.789, 205.256, 284.670, 254.887)
    ..cubicTo(286.610, 288.295, 298.960, 312.449, 339.172, 361.474)
    ..cubicTo(365.082, 393.062, 381.369, 414.269, 390.542, 428.359)
    ..cubicTo(398.032, 439.866, 407.277, 458.224, 408.935, 464.880)
    ..cubicTo(410.160, 469.805, 411.660, 469.377, 413.516, 463.575)
    ..close()
    ..moveTo(399.758, 262.444)
    ..cubicTo(382.960, 254.668, 378.232, 233.471, 390.246, 219.790)
    ..cubicTo(396.136, 213.081, 402.789, 210.116, 411.954, 210.116)
    ..cubicTo(418.522, 210.116, 420.632, 210.754, 425.958, 214.357)
    ..cubicTo(436.884, 221.745, 441.452, 236.477, 436.492, 248.324)
    ..cubicTo(434.500, 253.081, 425.405, 261.800, 420.482, 263.672)
    ..cubicTo(415.269, 265.653, 405.430, 265.071, 399.758, 262.444)
    ..close();

  static final List<Path> _letters = [
    Path()
      ..moveTo(51.547, -29.375)
      ..cubicTo(51.547, -22.844, 50.238, -17.250, 47.625, -12.594)
      ..cubicTo(45.008, -7.938, 41.348, -4.383, 36.641, -1.938)
      ..cubicTo(31.941, 0.508, 26.473, 1.734, 20.234, 1.734)
      ..cubicTo(15.910, 1.734, 12.094, 1.191, 8.781, 0.109)
      ..cubicTo(5.469, -0.973, 2.801, -2.148, 0.781, -3.422)
      ..cubicTo(-1.227, -4.691, -2.445, -5.613, -2.875, -6.188)
      ..lineTo(6.188, -28.000)
      ..cubicTo(6.812, -27.188, 7.629, -26.359, 8.641, -25.516)
      ..cubicTo(9.648, -24.680, 10.828, -23.961, 12.172, -23.359)
      ..cubicTo(13.516, -22.766, 14.930, -22.469, 16.422, -22.469)
      ..cubicTo(18.004, -22.469, 19.562, -22.773, 21.094, -23.391)
      ..cubicTo(22.625, -24.016, 23.895, -25.203, 24.906, -26.953)
      ..cubicTo(25.914, -28.711, 26.422, -31.250, 26.422, -34.562)
      ..lineTo(26.422, -95.031)
      ..lineTo(51.547, -95.031)
      ..close(),
    Path()
      ..moveTo(5.969, 0.000)
      ..lineTo(5.969, -59.109)
      ..lineTo(31.391, -59.109)
      ..lineTo(31.391, 0.000)
      ..close()
      ..moveTo(19.000, -68.172)
      ..cubicTo(15.113, -68.172, 11.816, -69.539, 9.109, -72.281)
      ..cubicTo(6.398, -75.020, 5.047, -78.285, 5.047, -82.078)
      ..cubicTo(5.047, -85.867, 6.398, -89.156, 9.109, -91.938)
      ..cubicTo(11.816, -94.719, 15.113, -96.109, 19.000, -96.109)
      ..cubicTo(21.551, -96.109, 23.879, -95.473, 25.984, -94.203)
      ..cubicTo(28.098, -92.930, 29.801, -91.238, 31.094, -89.125)
      ..cubicTo(32.395, -87.008, 33.047, -84.660, 33.047, -82.078)
      ..cubicTo(33.047, -78.285, 31.664, -75.020, 28.906, -72.281)
      ..cubicTo(26.145, -69.539, 22.844, -68.172, 19.000, -68.172)
      ..close(),
    Path()
      ..moveTo(36.641, 1.734)
      ..cubicTo(30.016, 1.734, 24.133, 0.414, 19.000, -2.219)
      ..cubicTo(13.863, -4.863, 9.832, -8.523, 6.906, -13.203)
      ..cubicTo(3.977, -17.891, 2.516, -23.281, 2.516, -29.375)
      ..cubicTo(2.516, -35.469, 3.977, -40.879, 6.906, -45.609)
      ..cubicTo(9.832, -50.336, 13.863, -54.055, 19.000, -56.766)
      ..cubicTo(24.133, -59.473, 30.016, -60.828, 36.641, -60.828)
      ..cubicTo(43.211, -60.828, 49.031, -59.473, 54.094, -56.766)
      ..cubicTo(59.164, -54.055, 63.129, -50.336, 65.984, -45.609)
      ..cubicTo(68.836, -40.879, 70.266, -35.469, 70.266, -29.375)
      ..cubicTo(70.266, -23.281, 68.836, -17.891, 65.984, -13.203)
      ..cubicTo(63.129, -8.523, 59.164, -4.863, 54.094, -2.219)
      ..cubicTo(49.031, 0.414, 43.211, 1.734, 36.641, 1.734)
      ..close()
      ..moveTo(36.641, -19.078)
      ..cubicTo(38.609, -19.078, 40.312, -19.492, 41.750, -20.328)
      ..cubicTo(43.195, -21.172, 44.301, -22.383, 45.062, -23.969)
      ..cubicTo(45.832, -25.551, 46.219, -27.398, 46.219, -29.516)
      ..cubicTo(46.219, -31.578, 45.832, -33.398, 45.062, -34.984)
      ..cubicTo(44.301, -36.566, 43.195, -37.801, 41.750, -38.688)
      ..cubicTo(40.312, -39.582, 38.609, -40.031, 36.641, -40.031)
      ..cubicTo(34.629, -40.031, 32.898, -39.582, 31.453, -38.688)
      ..cubicTo(30.016, -37.801, 28.891, -36.566, 28.078, -34.984)
      ..cubicTo(27.266, -33.398, 26.859, -31.578, 26.859, -29.516)
      ..cubicTo(26.859, -27.398, 27.266, -25.551, 28.078, -23.969)
      ..cubicTo(28.891, -22.383, 30.016, -21.172, 31.453, -20.328)
      ..cubicTo(32.898, -19.492, 34.629, -19.078, 36.641, -19.078)
      ..close(),
    Path()
      ..moveTo(6.047, -95.031)
      ..lineTo(31.094, -95.031)
      ..lineTo(31.094, -21.812)
      ..lineTo(64.500, -21.812)
      ..lineTo(64.500, 0.000)
      ..lineTo(6.047, 0.000)
      ..close(),
    Path()
      ..moveTo(26.641, -24.406)
      ..cubicTo(26.828, -22.820, 27.461, -21.441, 28.547, -20.266)
      ..cubicTo(29.629, -19.086, 31.066, -18.176, 32.859, -17.531)
      ..cubicTo(34.660, -16.883, 36.785, -16.562, 39.234, -16.562)
      ..cubicTo(41.629, -16.562, 43.883, -16.738, 46.000, -17.094)
      ..cubicTo(48.113, -17.457, 50.000, -17.953, 51.656, -18.578)
      ..cubicTo(53.312, -19.203, 54.617, -19.895, 55.578, -20.656)
      ..lineTo(65.016, -4.828)
      ..cubicTo(63.953, -3.910, 62.363, -2.945, 60.250, -1.938)
      ..cubicTo(58.145, -0.938, 55.254, -0.074, 51.578, 0.641)
      ..cubicTo(47.910, 1.367, 43.223, 1.734, 37.516, 1.734)
      ..cubicTo(30.891, 1.734, 24.938, 0.555, 19.656, -1.797)
      ..cubicTo(14.375, -4.148, 10.195, -7.691, 7.125, -12.422)
      ..cubicTo(4.051, -17.148, 2.516, -23.066, 2.516, -30.172)
      ..cubicTo(2.516, -35.922, 3.812, -41.113, 6.406, -45.750)
      ..cubicTo(9.000, -50.383, 12.742, -54.055, 17.641, -56.766)
      ..cubicTo(22.535, -59.473, 28.461, -60.828, 35.422, -60.828)
      ..cubicTo(42.086, -60.828, 47.867, -59.660, 52.766, -57.328)
      ..cubicTo(57.660, -55.004, 61.426, -51.488, 64.062, -46.781)
      ..cubicTo(66.707, -42.082, 68.031, -36.133, 68.031, -28.938)
      ..cubicTo(68.031, -28.551, 68.016, -27.781, 67.984, -26.625)
      ..cubicTo(67.961, -25.477, 67.906, -24.738, 67.812, -24.406)
      ..close()
      ..moveTo(44.062, -35.922)
      ..cubicTo(44.008, -37.504, 43.660, -38.922, 43.016, -40.172)
      ..cubicTo(42.367, -41.422, 41.441, -42.406, 40.234, -43.125)
      ..cubicTo(39.035, -43.844, 37.578, -44.203, 35.859, -44.203)
      ..cubicTo(34.172, -44.203, 32.676, -43.863, 31.375, -43.188)
      ..cubicTo(30.082, -42.520, 29.078, -41.570, 28.359, -40.344)
      ..cubicTo(27.641, -39.125, 27.234, -37.648, 27.141, -35.922)
      ..close(),
    Path()
      ..moveTo(49.609, -60.828)
      ..cubicTo(53.879, -60.828, 58.016, -59.988, 62.016, -58.312)
      ..cubicTo(66.023, -56.633, 69.336, -53.945, 71.953, -50.250)
      ..cubicTo(74.566, -46.551, 75.875, -41.727, 75.875, -35.781)
      ..lineTo(75.875, 0.000)
      ..lineTo(50.391, 0.000)
      ..lineTo(50.391, -31.672)
      ..cubicTo(50.391, -35.273, 49.609, -38.047, 48.047, -39.984)
      ..cubicTo(46.492, -41.930, 44.273, -42.906, 41.391, -42.906)
      ..cubicTo(39.523, -42.906, 37.727, -42.426, 36.000, -41.469)
      ..cubicTo(34.270, -40.508, 32.875, -39.164, 31.812, -37.438)
      ..cubicTo(30.758, -35.707, 30.234, -33.691, 30.234, -31.391)
      ..lineTo(30.234, 0.000)
      ..lineTo(4.750, 0.000)
      ..lineTo(4.750, -99.062)
      ..lineTo(30.234, -99.062)
      ..lineTo(30.234, -51.109)
      ..cubicTo(30.805, -52.691, 32.016, -54.211, 33.859, -55.672)
      ..cubicTo(35.711, -57.141, 38.004, -58.363, 40.734, -59.344)
      ..cubicTo(43.473, -60.332, 46.430, -60.828, 49.609, -60.828)
      ..close(),
  ];
}
