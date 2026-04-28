import 'package:flutter/material.dart';
import 'tool_entity.dart';

/// Pure domain entity representing a category in the business logic layer
class CategoryEntity {
  final IconData icon;
  final String name;
  final Color themeColor;
  final List<ToolEntity> tools;

  const CategoryEntity({
    required this.icon,
    required this.name,
    required this.themeColor,
    required this.tools,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
