import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:succulent_app/core/optimization/app_performance.dart';

/// A 3D flip card widget with front and back sides.
/// Optimized with RepaintBoundary and lazy back-side loading.
class FlipCardBento extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final VoidCallback onFlipRequested;

  const FlipCardBento({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
    required this.onFlipRequested,
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
    // Duration will be set in didChangeDependencies when context is available
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600), // default, overridden below
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final perf = AppPerformance.of(context);
    _controller.duration = perf.flipDuration;
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
    final perf = AppPerformance.of(context);

    // Low-mode: skip 3D transforms entirely, use a lightweight fade switch
    if (!perf.enable3DFlip) {
      return AnimatedSwitcher(
        duration: perf.shortDuration,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: widget.isFlipped
            ? KeyedSubtree(key: const ValueKey('back'), child: widget.back)
            : KeyedSubtree(key: const ValueKey('front'), child: widget.front),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double value = _animation.value;
          final double angle = value * math.pi;

          // Frame Rate Optimization: skip rendering at exact edge-on angle
          final bool isFrontVisible = angle < (math.pi / 2);
          final bool isEdgeOn =
              (angle - (math.pi / 2)).abs() < 0.05; // ~3 degrees margin

          if (isEdgeOn) {
            return const SizedBox();
          }

          final Matrix4 transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: isFrontVisible
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _hasShownBack ? widget.back : const SizedBox(),
                  ),
          );
        },
      ),
    );
  }
}
