import 'package:toolshub/core/domain/entities/category_entity.dart';
import 'package:toolshub/core/domain/entities/tool_entity.dart';

/// Abstract repository interface following Dependency Inversion Principle
/// This defines the contract for tool data operations without depending on implementation
abstract class ToolRepository {
  /// Stream of all categories with their tools
  Stream<List<CategoryEntity>> getCategories();
  
  /// Search tools by query
  List<ToolEntity> searchTools(String query);
  
  /// Get tool by ID
  Future<ToolEntity?> getToolById(String id);
  
  /// Get tools by category
  List<ToolEntity> getToolsByCategory(String categoryName);
}
