import 'package:flutter/material.dart';

/// Service interface for category-related business logic
/// Following Single Responsibility Principle - only handles category mapping
abstract class CategoryMappingService {
  /// Get icon for a category name
  IconData getIconForCategory(String category);
  
  /// Get theme color for a category name
  Color getColorForCategory(String category);
  
  /// Normalize category name (handle legacy mappings)
  String normalizeCategoryName(String category);
  
  /// Get all available category names in display order
  List<String> getAllCategories();
}
