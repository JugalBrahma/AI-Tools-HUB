import 'package:flutter/material.dart';
import 'package:toolshub/core/domain/services/category_mapping_service.dart';

/// Implementation of CategoryMappingService
/// Following Single Responsibility Principle - only handles category mapping logic
class CategoryMappingServiceImpl implements CategoryMappingService {
  @override
  IconData getIconForCategory(String category) {
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

  @override
  Color getColorForCategory(String category) {
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

  @override
  String normalizeCategoryName(String category) {
    String normalized = category.trim();
    if (normalized.isEmpty) return 'Other';

    // Legacy category mappings
    final lower = normalized.toLowerCase();
    if (lower == 'video') return 'Video Gen';
    if (lower == 'research') return 'Deep Research';
    if (lower == 'marketing') return 'SEO & Marketing';
    if (lower == 'music & audio' || lower == 'music' || lower == 'audio') {
      return 'AI Voice';
    }
    if (lower == 'coding' || lower == 'vibe coding' || lower == 'generative ui') {
      return 'Coding & Vibe Coding';
    }

    return normalized;
  }

  @override
  List<String> getAllCategories() {
    return [
      'Coding & Vibe Coding',
      'Image Gen',
      'Logo & Brand',
      'Video Gen',
      'Face Swap',
      'AI Voice',
      'Productivity',
      'Agents',
      'Deep Research',
      'Writing',
      'SEO & Marketing',
      'Social Media',
      'Chatbot',
      'Exam Prep',
      'Habit & Wellness',
      '3D & Gaming',
      'Web Scraping',
      'Legal & Finance',
      'Other',
    ];
  }
}
