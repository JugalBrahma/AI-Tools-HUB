import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterOption {
  final String label;
  final IconData icon;
  final List<String> options;
  String? selectedValue;

  FilterOption({
    required this.label,
    required this.icon,
    required this.options,
    this.selectedValue,
  });
}

class AssistantState {
  final List<String> activeFilters = [];
  final List<FilterOption> smartFilters = [
    FilterOption(
      label: 'Budget',
      icon: Icons.payments_outlined,
      options: ['Free', 'Under ₹500', 'Under ₹2000', 'Enterprise'],
    ),
    FilterOption(
      label: 'Freshness',
      icon: Icons.auto_awesome_outlined,
      options: ['Latest 2024', 'Industry Gold Stds', 'Beta Early Access'],
    ),
    FilterOption(
      label: 'Team Size',
      icon: Icons.people_outline_rounded,
      options: ['Solo Builder', 'Small Team (2-10)', 'Enterprise'],
    ),
    FilterOption(
      label: 'Integrations',
      icon: Icons.hub_outlined,
      options: ['API Access', 'Slack/Discord', 'Chrome Extension', 'Figma'],
    ),
  ];
}

class SuggestionChipData {
  final String label;
  final String? promptSnippet;

  SuggestionChipData(this.label, {this.promptSnippet});
}

final List<SuggestionChipData> suggestionChips = [
    SuggestionChipData('Coding', promptSnippet: 'coding tools'),
    SuggestionChipData('Design', promptSnippet: 'design tools'),
    SuggestionChipData('Writing', promptSnippet: 'writing tools'),
    SuggestionChipData('Video', promptSnippet: 'video tools'),
    SuggestionChipData('Marketing', promptSnippet: 'marketing tools'),
    SuggestionChipData('Cheapest option', promptSnippet: 'cheapest'),
    SuggestionChipData('Best for beginners', promptSnippet: 'for beginners'),
    SuggestionChipData('With API access', promptSnippet: 'with API access'),
    SuggestionChipData('Under ₹1000', promptSnippet: 'under ₹1000'),
    SuggestionChipData('Compare 2 tools', promptSnippet: 'Compare'),
];
