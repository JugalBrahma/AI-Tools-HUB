import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'tool_sliver_grid.dart';

class CategorySliverGroup extends StatelessWidget {
  const CategorySliverGroup({super.key, required this.category});
  final CategoryData category;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category.themeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: category.themeColor.withOpacity(0.18)),
                  ),
                  child: Icon(category.icon, color: category.themeColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Grid
        ToolSliverGrid(
          tools: category.tools,
          themeColor: category.themeColor,
        ),

        // Spacer + Divider
        const SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 48),
              Divider(color: Color(0xFF141418), thickness: 1),
              SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }
}
