import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/core/models/tool_model.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    required this.categories,
    required this.activeIndex,
    required this.onAll,
    required this.onTap,
    this.cyanColor = const Color(0xFF00D4AA),
  });
  final List<CategoryData> categories;
  final int activeIndex;
  final VoidCallback onAll;
  final Function(int) onTap;
  final Color cyanColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.start,
      children: [
        FilterChip(
          label: 'All Tools',
          isActive: activeIndex == -1,
          onTap: onAll,
          activeColor: cyanColor,
        ),
        ...List.generate(
          categories.length,
          (i) => FilterChip(
            label: categories[i].name,
            isActive: activeIndex == i,
            onTap: () => onTap(i),
            activeColor: categories[i].themeColor,
          ),
        ),
      ],
    );
  }
}

class FilterChip extends StatelessWidget {
  const FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.12)
              : const Color(0xFF0A0A0E),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isActive
                ? activeColor.withOpacity(0.4)
                : const Color(0xFF1C1C24),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? activeColor : Colors.white60,
          ),
        ),
      ),
    );
  }
}
