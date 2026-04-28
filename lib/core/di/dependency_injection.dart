import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toolshub/core/data/datasources/firebase_tool_datasource.dart';
import 'package:toolshub/core/data/datasources/tool_datasource.dart';
import 'package:toolshub/core/data/repositories/tool_repository_impl.dart';
import 'package:toolshub/core/data/services/category_mapping_service_impl.dart';
import 'package:toolshub/core/data/services/color_generation_service_impl.dart';
import 'package:toolshub/core/domain/repositories/tool_repository.dart';
import 'package:toolshub/core/domain/services/category_mapping_service.dart';
import 'package:toolshub/core/domain/services/color_generation_service.dart';

/// Dependency Injection Container
/// Following Dependency Inversion Principle - depends on abstractions, not concretions
class DependencyInjection {
  static DependencyInjection? _instance;
  
  static DependencyInjection get instance {
    _instance ??= DependencyInjection._();
    return _instance!;
  }
  
  DependencyInjection._();

  // Services
  late final CategoryMappingService _categoryMappingService;
  late final ColorGenerationService _colorGenerationService;
  
  // Datasources
  late final ToolDatasource _toolDatasource;
  
  // Repositories
  late final ToolRepository _toolRepository;

  /// Initialize all dependencies
  void initialize() {
    // Initialize services (business logic)
    _categoryMappingService = CategoryMappingServiceImpl();
    _colorGenerationService = ColorGenerationServiceImpl();
    
    // Initialize datasources (data access)
    _toolDatasource = FirebaseToolDatasource(
      FirebaseFirestore.instance,
      _categoryMappingService,
      _colorGenerationService,
    );
    
    // Initialize repositories (data coordination)
    _toolRepository = ToolRepositoryImpl(
      _toolDatasource,
      _categoryMappingService,
    );
  }

  // Getters for repositories (used by providers)
  ToolRepository get toolRepository => _toolRepository;
  
  // Getters for services (used by other parts of the app if needed)
  CategoryMappingService get categoryMappingService => _categoryMappingService;
  ColorGenerationService get colorGenerationService => _colorGenerationService;
}
