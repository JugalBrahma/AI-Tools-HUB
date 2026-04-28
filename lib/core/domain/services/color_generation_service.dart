import 'package:flutter/material.dart';

/// Service interface for color generation business logic
/// Following Single Responsibility Principle - only handles color generation
abstract class ColorGenerationService {
  /// Generate accent color from tool name
  Color generateAccentColor(String name);
  
  /// Generate gradient colors from tool name
  List<Color> generateGradient(String name);
}
