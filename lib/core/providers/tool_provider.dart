import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tool_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Isolate-safe data transfer object
// ─────────────────────────────────────────────────────────────────────────────

/// Plain-data bag passed TO the background isolate.
/// Must only contain primitive/serialisable Dart values.
class _IsolateInput {
  final List<Map<String, dynamic>> docs; // raw Firestore data
  const _IsolateInput(this.docs);
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP-LEVEL background function (required by compute())
// ─────────────────────────────────────────────────────────────────────────────

/// Runs in a background isolate — never touches the UI thread.
/// Returns ready-to-use [CategoryData] list.
List<CategoryData> _buildCategoriesInIsolate(_IsolateInput input) {
  // 1. Parse every document into a ToolInfo
  final tools = input.docs
      .map(
        (d) => ToolInfo.fromFirestore(
          d['data'] as Map<String, dynamic>,
          d['id'] as String,
          categoryFromPath: d['parentId'] as String?,
        ),
      )
      .where((t) => t.name.isNotEmpty)
      .toList();

  // 2. Bucket map — order here defines UI display order
  final Map<String, List<ToolInfo>> grouped = {
    'Coding & Vibe Coding': [],
    'Image Gen': [],
    'Logo & Brand': [],
    'Video Gen': [],
    'Face Swap': [],
    'AI Voice': [],
    'Productivity': [],
    'Agents': [],
    'Deep Research': [],
    'Writing': [],
    'SEO & Marketing': [],
    'Social Media': [],
    'Chatbot': [],
    'Exam Prep': [],
    'Habit & Wellness': [],
    '3D & Gaming': [],
    'Web Scraping': [],
    'Legal & Finance': [],
    'Other': [],
  };

  for (final tool in tools) {
    String cat = 'Other';
    String toolCat = tool.category.toLowerCase().trim();

    // Legacy category mappings
    if (toolCat == 'video') toolCat = 'video gen';
    if (toolCat == 'research') toolCat = 'deep research';
    if (toolCat == 'marketing') toolCat = 'seo & marketing';
    if (toolCat == 'music & audio' ||
        toolCat == 'music' ||
        toolCat == 'audio') {
      toolCat = 'ai voice';
    }
    if (toolCat == 'coding' ||
        toolCat == 'vibe coding' ||
        toolCat == 'generative ui') {
      toolCat = 'coding & vibe coding';
    }

    for (final k in grouped.keys) {
      if (k.toLowerCase().trim() == toolCat) {
        cat = k;
        break;
      }
    }
    grouped[cat]!.add(tool);
  }

  // 3. Convert to CategoryData — filter out empty buckets (except 'Other' if populated)
  return grouped.entries
      .where((e) => e.value.isNotEmpty)
      .map(
        (e) => CategoryData(
          icon: _iconFor(e.key),
          name: e.key,
          themeColor: _colorFor(e.key),
          tools: e.value,
        ),
      )
      .toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers (top-level so they are reachable from the isolate)
// ─────────────────────────────────────────────────────────────────────────────

IconData _iconFor(String category) {
  switch (category) {
    case 'Coding & Vibe Coding':
      return Icons.code_rounded;
    case 'Image Gen':
      return Icons.image_rounded;
    case 'Logo & Brand':
      return Icons.brush_rounded;
    case 'Video Gen':
      return Icons.video_collection_rounded;
    case 'Face Swap':
      return Icons.face_retouching_natural_rounded;
    case 'AI Voice':
      return Icons.settings_voice_rounded;
    case 'Productivity':
      return Icons.bolt_rounded;
    case 'Agents':
      return Icons.smart_toy_rounded;
    case 'Deep Research':
      return Icons.science_rounded;
    case 'Writing':
      return Icons.edit_note_rounded;
    case 'SEO & Marketing':
      return Icons.campaign_rounded;
    case 'Social Media':
      return Icons.share_rounded;
    case 'Chatbot':
      return Icons.chat_bubble_outline_rounded;
    case 'Exam Prep':
      return Icons.school_rounded;
    case 'Habit & Wellness':
      return Icons.self_improvement_rounded;
    case '3D & Gaming':
      return Icons.sports_esports_rounded;
    case 'Web Scraping':
      return Icons.data_object_rounded;
    case 'Legal & Finance':
      return Icons.account_balance_rounded;
    default:
      return Icons.apps_rounded;
  }
}

Color _colorFor(String category) {
  switch (category) {
    case 'Coding & Vibe Coding':
      return const Color(0xFF0984E3);
    case 'Image Gen':
      return const Color(0xFF00B894);
    case 'Logo & Brand':
      return const Color(0xFFFDCB6E);
    case 'Video Gen':
      return const Color(0xFFE84393);
    case 'Face Swap':
      return const Color(0xFFFF7675);
    case 'AI Voice':
      return const Color(0xFFE17055);
    case 'Productivity':
      return const Color(0xFF6C5CE7);
    case 'Agents':
      return const Color(0xFF0984E3);
    case 'Deep Research':
      return const Color(0xFF00CEC9);
    case 'Writing':
      return const Color(0xFF00B894);
    case 'SEO & Marketing':
      return const Color(0xFFFF7675);
    case 'Social Media':
      return const Color(0xFF0984E3);
    case 'Chatbot':
      return const Color(0xFFFDCB6E);
    case 'Exam Prep':
      return const Color(0xFF6C5CE7);
    case 'Habit & Wellness':
      return const Color(0xFF00B894);
    case '3D & Gaming':
      return const Color(0xFFE84393);
    case 'Web Scraping':
      return const Color(0xFF00CEC9);
    case 'Legal & Finance':
      return const Color(0xFFE17055);
    default:
      return const Color(0xFFB2BEC3);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class ToolProvider with ChangeNotifier {
  List<CategoryData> _categories = [];
  bool _isLoading = true;

  ToolProvider() {
    _fetchTools();
  }

  List<CategoryData> get categories => _categories;
  bool get isLoading => _isLoading;

  void _fetchTools() {
    FirebaseFirestore.instance
        .collectionGroup('tools')
        .snapshots()
        .listen(
          (snapshot) async {
            // ── Step 1: Extract raw serialisable data on the main thread (fast) ──
            final rawDocs = snapshot.docs
                .where((doc) => doc.reference.path.contains('ai_tools/'))
                .map(
                  (doc) => {
                    'data': doc.data(),
                    'id': doc.id,
                    'parentId': doc.reference.parent.parent?.id,
                  },
                )
                .toList();

            // ── Step 2: Heavy processing in background isolate ────────────────
            final built = await compute(
              _buildCategoriesInIsolate,
              _IsolateInput(rawDocs),
            );

            // ── Step 3: Update state on the main thread ───────────────────────
            _categories = built;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error fetching tools: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  List<ToolInfo> searchTools(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    final results = <ToolInfo>[];
    for (final cat in _categories) {
      results.addAll(
        cat.tools.where(
          (t) => t.searchName.contains(q) || t.searchDescription.contains(q),
        ),
      );
    }
    return results;
  }
}
