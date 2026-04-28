import 'package:flutter/material.dart';
import 'package:toolshub/core/domain/services/color_generation_service.dart';

/// Implementation of ColorGenerationService
/// Following Single Responsibility Principle - only handles color generation logic
class ColorGenerationServiceImpl implements ColorGenerationService {
  @override
  Color generateAccentColor(String name) {
    if (name.isEmpty) return const Color(0xFF6C5CE7);
    final int hash = name.hashCode;
    final double hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.8, 0.6).toColor();
  }

  @override
  List<Color> generateGradient(String name) {
    if (name.isEmpty) return const [Color(0xFF6C5CE7), Color(0xFF4834D4)];
    final int hash = name.hashCode;
    final double hue = (hash % 360).toDouble();
    final color = HSLColor.fromAHSL(1.0, hue, 0.8, 0.6).toColor();
    final darkColor = HSLColor.fromAHSL(1.0, hue, 0.9, 0.4).toColor();
    return [color, darkColor];
  }
}
