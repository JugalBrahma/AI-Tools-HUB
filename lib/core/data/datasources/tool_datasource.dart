import 'package:toolshub/core/domain/entities/tool_entity.dart';

/// Abstract datasource interface
/// Following Dependency Inversion Principle - high-level modules don't depend on low-level modules
abstract class ToolDatasource {
  /// Stream of raw tool data from the data source
  Stream<List<ToolEntity>> getTools();
  
  /// Get tool by ID from data source
  Future<ToolEntity?> getToolById(String id);
}
