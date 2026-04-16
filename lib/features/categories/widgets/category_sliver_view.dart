import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/features/categories/widgets/tool_card.dart';

class CategorySliverView extends StatelessWidget {
  const CategorySliverView({
    super.key,
    required this.categories,
    required this.searchQuery,
    required this.activeFilterIndex,
  });

  final List<CategoryData> categories;
  final String searchQuery;
  final int activeFilterIndex;

  @override
  Widget build(BuildContext context) {
    // If searching, we show search results as a single grid sliver
    if (searchQuery.isNotEmpty) {
      final results = categories
          .expand((c) => c.tools)
          .where(
            (t) =>
                t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                t.description.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();

      return SliverPadding(
        padding: const EdgeInsets.only(top: 32.0),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ToolCard(
              tool: results[index],
              themeColor: Colors.blueAccent, // Default search color
            ),
            childCount: results.length,
          ),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 340,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.82,
          ),
        ),
      );
    }

    // Filter categories based on active index
    final filteredCategories = activeFilterIndex == -1
        ? categories
        : [categories[activeFilterIndex]];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final category = filteredCategories[index];
        return _SliverCategoryGroup(category: category);
      }, childCount: filteredCategories.length),
    );
  }
}

class _SliverCategoryGroup extends StatelessWidget {
  const _SliverCategoryGroup({required this.category});
  final CategoryData category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header (Static within the list)
        Padding(
          padding: const EdgeInsets.only(top: 48, bottom: 24),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.themeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: category.themeColor.withOpacity(0.18),
                  ),
                ),
                child: Icon(
                  category.icon,
                  color: category.themeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${category.tools.length} tools',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF555566),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Grid of tools for this category
        // Note: Using a GridView with shrinkWrap here is still "per-category" lazy.
        // To be truly item-lazy across all categories, we'd need to flatten the list.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: category.tools.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 340,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, i) => ToolCard(
            tool: category.tools[i],
            themeColor: category.themeColor,
          ),
        ),

        const SizedBox(height: 16),
        const Divider(color: Color(0xFF141418), thickness: 1),
      ],
    );
  }
}
