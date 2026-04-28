import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toolshub/core/data/datasources/tool_datasource.dart';
import 'package:toolshub/core/domain/entities/tool_entity.dart';
import 'package:toolshub/core/domain/services/category_mapping_service.dart';
import 'package:toolshub/core/domain/services/color_generation_service.dart';

/// Firebase implementation of ToolDatasource
/// Concrete implementation that depends on Firebase
class FirebaseToolDatasource implements ToolDatasource {
  final FirebaseFirestore _firestore;
  final CategoryMappingService _categoryMappingService;
  final ColorGenerationService _colorGenerationService;

  FirebaseToolDatasource(
    this._firestore,
    this._categoryMappingService,
    this._colorGenerationService,
  );

  @override
  Stream<List<ToolEntity>> getTools() {
    return _firestore
        .collectionGroup('tools')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.reference.path.contains('ai_tools/'))
          .map((doc) => _mapToEntity(doc.data(), doc.id, 
              doc.reference.parent.parent?.id))
          .toList();
    });
  }

  @override
  Future<ToolEntity?> getToolById(String id) async {
    // This would need to be implemented based on your data structure
    // For now, returning null as placeholder
    return null;
  }

  ToolEntity _mapToEntity(
    Map<String, dynamic> data,
    String docId,
    String? categoryFromPath,
  ) {
    final name = data['name'] ?? '';
    final normalizedCategory = _categoryMappingService.normalizeCategoryName(
      data['category']?.toString() ?? categoryFromPath ?? 'Other',
    );
    
    return ToolEntity(
      id: docId,
      name: name,
      url: data['url'] ?? '',
      description: data['description'] ?? '',
      logo: _sanitizeLogoUrl(data['logo'] ?? ''),
      category: normalizedCategory,
      pricing: data['pricing'] ?? '',
      accentColor: _colorGenerationService.generateAccentColor(name),
      logoGradient: _colorGenerationService.generateGradient(name),
      searchName: name.toLowerCase(),
      searchDescription: (data['description'] ?? '').toLowerCase(),
    );
  }

  String _sanitizeLogoUrl(String url) {
    if (url.isEmpty) return url;
    String finalUrl = url.trim();
    if (finalUrl.isEmpty) return '';
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }
    return finalUrl;
  }
}
