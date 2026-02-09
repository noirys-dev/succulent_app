import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A 3D flip card widget with front and back sides.
/// Optimized with RepaintBoundary and lazy back-side loading.
class FlipCardBento extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback onFlipRequested;
  final Duration animationDuration;

  const FlipCardBento({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
    required this.onFlipRequested,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<FlipCardBento> createState() => _FlipCardBentoState();
}

class _FlipCardBentoState extends State<FlipCardBento>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Track if we've ever shown the back (for lazy loading)
  bool _hasShownBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    if (widget.isFlipped) {
      _controller.value = 1.0;
      _hasShownBack = true;
    }
  }

  @override
  void didUpdateWidget(FlipCardBento oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _hasShownBack = true;
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate rotation angle: 0 to pi (180 degrees)
          final angle = _animation.value * math.pi;

          // Determine which side to show
          // Show front when angle < pi/2 (less than 90 degrees)
          final showFront = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            child: showFront
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _hasShownBack
                        ? widget.back
                        : const SizedBox.shrink(), // Lazy load
                  ),
          );
        },
      ),
    );
  }
}
