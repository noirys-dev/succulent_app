import 'dart:ui';
import 'package:flutter/material.dart';

enum PerformanceMode { low, mid, high }

class AppPerformance {
  final PerformanceMode mode;

  AppPerformance(this.mode);

  // ─── Factory ───────────────────────────────────────────────
  factory AppPerformance.of(BuildContext context) {
    final bool isLowPower = MediaQuery.of(context).disableAnimations;
    if (isLowPower) return AppPerformance(PerformanceMode.low);
    return AppPerformance(PerformanceMode.high);
  }

  // ─── Graphic Capabilities ──────────────────────────────────
  bool get useGlassmorphism => mode == PerformanceMode.high;
  bool get useComplexAnimations => mode != PerformanceMode.low;
  bool get enable3DFlip => mode != PerformanceMode.low;

  // ─── Shadow Configuration ─────────────────────────────────
  double get shadowBlurRadius => mode == PerformanceMode.high ? 20.0 : 4.0;
  double get shadowBlurRadiusSmall => mode == PerformanceMode.high ? 8.0 : 2.0;
  double get shadowOffsetY => mode == PerformanceMode.high ? 8.0 : 2.0;
  double get shadowOffsetYSmall => mode == PerformanceMode.high ? 2.0 : 1.0;

  // ─── Glassmorphism / Blur ─────────────────────────────────
  double get glassSigma => mode == PerformanceMode.high ? 10.0 : 0.0;
  double get glassSigmaLight => mode == PerformanceMode.high ? 8.0 : 0.0;

  // ─── Animation Durations ──────────────────────────────────
  Duration get animationDuration => mode == PerformanceMode.low
      ? Duration.zero
      : const Duration(milliseconds: 400);

  Duration get microDuration => mode == PerformanceMode.low
      ? Duration.zero
      : const Duration(milliseconds: 200);

  Duration get shortDuration => mode == PerformanceMode.low
      ? Duration.zero
      : const Duration(milliseconds: 300);

  Duration get mediumDuration => mode == PerformanceMode.low
      ? Duration.zero
      : const Duration(milliseconds: 500);

  Duration get flipDuration => mode == PerformanceMode.low
      ? Duration.zero
      : const Duration(milliseconds: 600);

  // ─── Adaptive Blur Helper ─────────────────────────────────
  /// On high-end: wraps [child] with BackdropFilter.
  /// On low-end: returns [child] directly — zero GPU cost.
  Widget adaptiveBlur({
    required Widget child,
    double? sigmaX,
    double? sigmaY,
  }) {
    if (!useGlassmorphism) return child;
    final sx = sigmaX ?? glassSigma;
    final sy = sigmaY ?? glassSigma;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sx, sigmaY: sy),
      child: child,
    );
  }
}
