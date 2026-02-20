import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedSucculent extends StatefulWidget {
  final int streakCount;
  final double size;

  const AnimatedSucculent({
    super.key,
    required this.streakCount,
    required this.size,
  });

  @override
  State<AnimatedSucculent> createState() => _AnimatedSucculentState();
}

class _AnimatedSucculentState extends State<AnimatedSucculent>
    with SingleTickerProviderStateMixin {
  late AnimationController _effectController;

  @override
  void initState() {
    super.initState();
    _effectController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _effectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 0 daily: stage0.png
    // 1 daily: succulent_stage1.png
    // 2 daily: succulent_stage1.png + sunlight
    // 3 daily: succulent_stage2.png
    // 4 daily: succulent_stage2.png + water drops
    // 5 daily: succulent_stage3.png
    // 6+ daily: succulent_stage3.png + sunlight

    String imageAsset;
    bool showSunlight = false;
    bool showWaterDrops = false;

    if (widget.streakCount == 0) {
      imageAsset = 'assets/images/succulent/succulent_stage0.png';
    } else if (widget.streakCount == 1) {
      imageAsset = 'assets/images/succulent/succulent_stage1.png';
    } else if (widget.streakCount == 2) {
      imageAsset = 'assets/images/succulent/succulent_stage1.png';
      showSunlight = true;
    } else if (widget.streakCount == 3) {
      imageAsset = 'assets/images/succulent/succulent_stage2.png';
    } else if (widget.streakCount == 4) {
      imageAsset = 'assets/images/succulent/succulent_stage2.png';
      showWaterDrops = true;
    } else if (widget.streakCount == 5) {
      imageAsset = 'assets/images/succulent/succulent_stage3.png';
    } else {
      // >= 6
      imageAsset = 'assets/images/succulent/succulent_stage3.png';
      showSunlight = true;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: ValueKey('${widget.streakCount}_${widget.size}'),
        width: widget.size,
        height: widget.size,
        // RepaintBoundary for high performance, so animations don't trigger layout rebuilds of parent
        child: RepaintBoundary(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _effectController,
                builder: (context, _) {
                  Widget plantImage = Image.asset(
                    imageAsset,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
                    // Avoid heavy memory usage on memory-constrained devices by capping cache width
                    cacheWidth: (widget.size * 2).toInt(),
                  );

                  if (showSunlight) {
                    return ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            const Color(0xFFFFF6D9).withValues(
                                alpha: 0.2 + 0.2 * _effectController.value),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: [
                            0.0,
                            0.3 + 0.4 * _effectController.value,
                            1.0,
                          ],
                        ).createShader(bounds);
                      },
                      child: plantImage,
                    );
                  }

                  return plantImage;
                },
              ),

              // Water Drops Effect
              if (showWaterDrops)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _effectController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _WaterDropPainter(
                            animationValue: _effectController.value,
                          ),
                        );
                      },
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

class _WaterDropPainter extends CustomPainter {
  final double animationValue;

  _WaterDropPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final highlightPaint = Paint()..style = PaintingStyle.fill;

    // Fixed points on the succulent where water droplets form
    final points = [
      Offset(size.width * 0.4, size.height * 0.45),
      Offset(size.width * 0.55, size.height * 0.40),
      Offset(size.width * 0.45, size.height * 0.65),
    ];

    for (int i = 0; i < points.length; i++) {
      // Phase shifted for each drop
      double phase = (animationValue + i * 0.33) % 1.0;

      // Drop moves smoothly downwards
      final dropOffset = Offset(
        points[i].dx,
        points[i].dy + (phase * size.height * 0.08),
      );

      // Smooth opacity (0 -> 1 -> 0)
      final opacity = math.sin(phase * math.pi);

      paint.color = const Color(0xFFE0F7FA).withValues(alpha: 0.6 * opacity);
      highlightPaint.color = Colors.white.withValues(alpha: 0.9 * opacity);

      // Main drop body
      canvas.drawCircle(dropOffset, size.width * 0.015, paint);
      // Shine highlight for glassy effect
      canvas.drawCircle(
        dropOffset.translate(-size.width * 0.003, -size.width * 0.003),
        size.width * 0.005,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaterDropPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
