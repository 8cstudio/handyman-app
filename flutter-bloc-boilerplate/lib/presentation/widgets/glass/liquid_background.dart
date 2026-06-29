import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

class LiquidBackground extends StatefulWidget {
  final Widget child;

  const LiquidBackground({super.key, required this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _LiquidBlobPainter(
                  progress: _controller.value,
                  baseColor: GlassStyle.liquidBase(context),
                  blobColors: GlassStyle.liquidBlobColors(context),
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _LiquidBlobPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final List<Color> blobColors;

  _LiquidBlobPainter({
    required this.progress,
    required this.baseColor,
    required this.blobColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    final specs = [
      _BlobSpec(0.18, 0.22, 0.42, 0.0),
      _BlobSpec(0.78, 0.12, 0.36, 0.33),
      _BlobSpec(0.62, 0.72, 0.48, 0.66),
      _BlobSpec(0.12, 0.78, 0.34, 0.85),
    ];

    for (var i = 0; i < specs.length && i < blobColors.length; i++) {
      final spec = specs[i];
      final angle = progress * math.pi * 2 + spec.phase;
      final dx = spec.anchorX * size.width +
          math.cos(angle) * size.width * spec.drift;
      final dy = spec.anchorY * size.height +
          math.sin(angle * 0.85) * size.height * spec.drift;
      final radius = size.shortestSide * spec.radiusFactor;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            blobColors[i],
            blobColors[i].withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiquidBlobPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.blobColors != blobColors;
  }
}

class _BlobSpec {
  final double anchorX;
  final double anchorY;
  final double radiusFactor;
  final double phase;
  final double drift;

  const _BlobSpec(
    this.anchorX,
    this.anchorY,
    this.radiusFactor,
    this.phase, {
    this.drift = 0.08,
  });
}
