import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class TacticalHover extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableNoise;
  final double scale;

  const TacticalHover({
    super.key,
    required this.child,
    this.onTap,
    this.enableNoise = true,
    this.scale = 1.05,
  });

  @override
  State<TacticalHover> createState() => _TacticalHoverState();
}

class _TacticalHoverState extends State<TacticalHover> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _flickerController;

  @override
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
        if (_isHovered) setState(() {});
      });
  }

  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _flickerController.repeat();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _flickerController.stop();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isHovered ? widget.scale : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Stack(
            children: [
              // Flicker Effect
              AnimatedBuilder(
                animation: _flickerController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _isHovered
                        ? (0.9 + (math.Random().nextDouble() * 0.1))
                        : 1.0,
                    child: widget.child,
                  );
                },
              ),
              // Subtle Noise (Ameisenrennen)
              if (_isHovered && widget.enableNoise)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: NoisePainter(_flickerController.value),
                    ),
                  ),
                ),
              // Inner Glow on hover
              if (_isHovered)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoisePainter extends CustomPainter {
  final double seed;
  NoisePainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random((seed * 10000).toInt());
    final paint = Paint()..strokeWidth = 1.0;

    for (int i = 0; i < 60; i++) {
      paint.color = Colors.white.withValues(alpha: random.nextDouble() * 0.06);
      canvas.drawPoints(
        ui.PointMode.points,
        [Offset(random.nextDouble() * size.width, random.nextDouble() * size.height)],
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant NoisePainter oldDelegate) => oldDelegate.seed != seed;
}
