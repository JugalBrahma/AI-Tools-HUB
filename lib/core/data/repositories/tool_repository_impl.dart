import 'package:toolshub/core/data/datasources/tool_datasource.dart';
import 'package:toolshub/core/domain/entities/category_entity.dart';
import 'package:toolshub/core/domain/entities/tool_entity.dart';
import 'package:toolshub/core/domain/repositories/tool_repository.dart';
import 'package:toolshub/core/domain/services/category_mapping_service.dart';

/// Implementation of ToolRepository
/// Coordinates between datasource and business logic services
/// Following Single Responsibility Principle - only handles data coordination
class ToolRepositoryImpl implements ToolRepository {
  final ToolDatasource _datasource;
  final CategoryMappingService _categoryMappingService;

  ToolRepositoryImpl(
    this._datasource,
    this._categoryMappingService,
  );

  @override
  Stream<List<CategoryEntity>> getCategories() {
    return _datasource.getTools().map((tools) {
      return _groupToolsByCategory(tools);
    });
  }

  @override
  List<ToolEntity> searchTools(String query) {
    // This would need to cache the current tools or get them from the stream
    // For now, returning empty as placeholder
    return [];
  }

  @override
  Future<ToolEntity?> getToolById(String id) {
    return _datasource.getToolById(id);
  }

  @override
  List<ToolEntity> getToolsByCategory(String categoryName) {
    // This would need to cache the current tools or get them from the stream
    // For now, returning empty as placeholder
    return [];
  }

  List<CategoryEntity> _groupToolsByCategory(List<ToolEntity> tools) {
    final Map<String, List<ToolEntity>> grouped = {};
    
    // Initialize all categories
    for (final category in _categoryMappingService.getAllCategories()) {
      grouped[category] = [];
    }

    // Group tools by category
    for (final tool in tools) {
      final normalizedCategory = _categoryMappingService.normalizeCategoryName(
        tool.category,
      );
      
      // Find matching category
      String matchedCategory = 'Other';
      for (final category in grouped.keys) {
        if (category.toLowerCase() == normalizedCategory.toLowerCase()) {
          matchedCategory = category;
          break;
        }
      }
      
      grouped[matchedCategory]!.add(tool);
    }

    // Convert to CategoryEntity, filtering out empty categories
    return grouped.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => CategoryEntity(
              icon: _categoryMappingService.getIconForCategory(entry.key),
              name: entry.key,
              themeColor: _categoryMappingService.getColorForCategory(entry.key),
              tools: entry.value,
            ))
        .toList();
  }
}
