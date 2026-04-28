import 'package:flutter/material.dart';
import 'package:toolshub/core/di/dependency_injection.dart';
import 'package:toolshub/core/domain/entities/category_entity.dart';
import 'package:toolshub/core/domain/entities/tool_entity.dart';
import 'package:toolshub/core/domain/repositories/tool_repository.dart';

/// Refactored ToolProvider following SOLID principles
/// Single Responsibility: Only handles UI state management
/// Dependency Inversion: Depends on repository abstraction, not implementation
class ToolProviderRefactored with ChangeNotifier {
  final ToolRepository _repository = DependencyInjection.instance.toolRepository;
  
  List<CategoryEntity> _categories = [];
  bool _isLoading = true;
  List<ToolEntity> _allTools = []; // Cache for search

  ToolProviderRefactored() {
    _initialize();
  }

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;

  void _initialize() {
    _repository.getCategories().listen(
      (categories) {
        _categories = categories;
        _allTools = categories.expand((cat) => cat.tools).toList();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error fetching categories: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Search tools by query - delegates to repository
  List<ToolEntity> searchTools(String query) {
    if (query.isEmpty) return [];
    
    final q = query.toLowerCase();
    return _allTools.where(
      (tool) => tool.searchName.contains(q) || tool.searchDescription.contains(q),
    ).toList();
  }

  /// Get tools by category - delegates to repository
  List<ToolEntity> getToolsByCategory(String categoryName) {
    return _repository.getToolsByCategory(categoryName);
  }
}
