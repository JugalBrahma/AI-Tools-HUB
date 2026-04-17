import 'package:flutter/material.dart';

enum SelectionType { single, multi, toggle }

class FilterConfig {
  final String label;
  final IconData icon;
  final List<String> options;
  final SelectionType type;
  final String? description;

  FilterConfig({
    required this.label,
    required this.icon,
    required this.options,
    this.type = SelectionType.single,
    this.description,
  });
}

class AssistantState {
  final Map<String, dynamic> selections = {};

  final List<FilterConfig> filters = [
    FilterConfig(
      label: 'Category',
      icon: Icons.category_outlined,
      options: [
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
        'Other'
      ],
    ),
    FilterConfig(
      label: 'Budget',
      icon: Icons.payments_outlined,
      options: ['Free', 'Cheap', 'Moderate', 'Expensive', 'Enterprise', 'Not sure'],
    ),
    FilterConfig(
      label: 'Priority',
      icon: Icons.bolt_outlined,
      options: ['Speed', 'Low cost', 'Quality', 'Ease of use', 'Power/features', 'Balanced / Other'],
    ),
    FilterConfig(
      label: 'Must-haves',
      icon: Icons.check_box_outlined,
      type: SelectionType.multi,
      options: ['API access', 'Chat', 'Code completion', 'Image generation', 'Video generation', 'Templates', 'Team collaboration', 'Privacy', 'Other'],
    ),
    FilterConfig(
      label: 'Integrations',
      icon: Icons.hub_outlined,
      type: SelectionType.multi,
      options: ['VS Code', 'GitHub', 'Firebase', 'Figma', 'Notion', 'Slack', 'Google Drive', 'Other'],
    ),
    FilterConfig(
      label: 'Latest info',
      icon: Icons.verified_user_outlined,
      type: SelectionType.toggle,
      options: ['Verify live', 'General / Not sure'],
    ),
    FilterConfig(
      label: 'Avoid',
      icon: Icons.block_flipped,
      type: SelectionType.multi,
      options: ['Expensive tools', 'Separate app', 'Complex setup', 'No free plan', 'Requires API key', 'Other', 'Nothing specific'],
      description: 'Negative constraints to sharpen results',
    ),
  ];
}
