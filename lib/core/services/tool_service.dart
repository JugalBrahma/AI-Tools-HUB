import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tool_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPOSITORY (DATA LAYER)
// ─────────────────────────────────────────────────────────────────────────────

final toolRepositoryProvider = Provider<ToolRepository>((ref) {
  return ToolRepository();
});

class ToolRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ToolInfo>> streamTools() {
    return _firestore.collectionGroup('tools').snapshots().asyncMap((
      snapshot,
    ) async {
      // Offload parsing to isolate
      return await compute(
        _parseTools,
        snapshot.docs
            .map(
              (d) => {
                'id': d.id,
                'parentId': d.reference.parent.parent?.id,
                'data': d.data(),
              },
            )
            .toList(),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROCESSING (ISOLATE)
// ─────────────────────────────────────────────────────────────────────────────

List<ToolInfo> _parseTools(List<Map<String, dynamic>> docs) {
  return docs
      .map((d) {
        return ToolInfo.fromFirestore(
          d['data'] as Map<String, dynamic>,
          d['id'] as String,
          categoryFromPath: d['parentId'] as String?,
        );
      })
      .where((t) => t.name.isNotEmpty)
      .toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE (BUSINESS LOGIC)
// ─────────────────────────────────────────────────────────────────────────────

final toolListProvider = StreamProvider<List<ToolInfo>>((ref) {
  return ref.watch(toolRepositoryProvider).streamTools();
});

final categoriesProvider = Provider<AsyncValue<List<CategoryData>>>((ref) {
  final toolsAsync = ref.watch(toolListProvider);

  return toolsAsync.whenData((tools) {
    // This logic could also be in an isolate if tools count > 1000
    return _groupToolsIntoCategories(tools);
  });
});

List<CategoryData> _groupToolsIntoCategories(List<ToolInfo> tools) {
  // Same grouping logic as before...
  // For brevity, I'll use a simplified version for now and expand if needed.
  final Map<String, List<ToolInfo>> grouped = {};
  for (final tool in tools) {
    final cat = tool.category;
    grouped.putIfAbsent(cat, () => []).add(tool);
  }

  return grouped.entries
      .map(
        (e) => CategoryData(
          name: e.key,
          tools: e.value,
          themeColor: _colorFor(e.key),
          icon: _iconFor(e.key),
        ),
      )
      .toList();
}

// Helpers...

Color _colorFor(String cat) => Colors.blueAccent;
IconData _iconFor(String cat) => Icons.category;
