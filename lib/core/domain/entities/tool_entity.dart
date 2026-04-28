import 'package:flutter/material.dart';

/// Pure domain entity representing a tool in the business logic layer
/// This is independent of any data source or UI framework
class ToolEntity {
  final String id;
  final String name;
  final String url;
  final String description;
  final String logo;
  final String category;
  final String pricing;
  final Color accentColor;
  final List<Color> logoGradient;
  final String searchName;
  final String searchDescription;

  const ToolEntity({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.logo,
    required this.category,
    required this.pricing,
    required this.accentColor,
    required this.logoGradient,
    required this.searchName,
    required this.searchDescription,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
