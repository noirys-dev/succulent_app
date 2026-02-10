import 'package:flutter/material.dart';

enum PerformanceMode { low, mid, high }

class AppPerformance {
  final PerformanceMode mode;

  AppPerformance(this.mode);

  // cihaz segmentini belirleyen fabrika metod
  factory AppPerformance.of(BuildContext context) {
    // 1. sistem ayarlarını kontrol et (reduce motion veya low power mode)
    final bool isLowPower = MediaQuery.of(context).disableAnimations;

    if (isLowPower) return AppPerformance(PerformanceMode.low);

    // 2. buraya ileride cihaz ram veya model kontrolü eklenebilir
    // şimdilik varsayılan olarak high dönelim
    return AppPerformance(PerformanceMode.high);
  }

  // grafik ayarları
  bool get useGlassmorphism => mode == PerformanceMode.high;
  bool get useComplexAnimations => mode != PerformanceMode.low;
  double get shadowBlurRadius => mode == PerformanceMode.high ? 20.0 : 4.0;

  // animasyon süreleri
  Duration get animationDuration => mode == PerformanceMode.low
      ? Duration.zero
      : const Duration(milliseconds: 400);

  // bento card özel ayarları
  bool get enable3DFlip => mode != PerformanceMode.low;
}
