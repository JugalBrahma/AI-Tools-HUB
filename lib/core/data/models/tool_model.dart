import 'package:toolshub/core/domain/entities/tool_entity.dart';

/// Data transfer object for tools
/// Used for data mapping between datasources and domain entities
class ToolModel {
  final String id;
  final String name;
  final String url;
  final String description;
  final String logo;
  final String category;
  final String pricing;

  ToolModel({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.logo,
    required this.category,
    required this.pricing,
  });

  /// Convert to domain entity
  ToolEntity toEntity({
    required String searchName,
    required String searchDescription,
    required dynamic accentColor,
    required List<dynamic> logoGradient,
  }) {
    return ToolEntity(
      id: id,
      name: name,
      url: url,
      description: description,
      logo: logo,
      category: category,
      pricing: pricing,
      accentColor: accentColor,
      logoGradient: logoGradient.cast(),
      searchName: searchName,
      searchDescription: searchDescription,
    );
  }

  /// Create from Firestore data
  factory ToolModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ToolModel(
      id: docId,
      name: data['name'] ?? '',
      url: data['url'] ?? '',
      description: data['description'] ?? '',
      logo: data['logo'] ?? '',
      category: data['category'] ?? '',
      pricing: data['pricing'] ?? '',
    );
  }
}
