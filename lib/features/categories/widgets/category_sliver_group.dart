import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'tool_sliver_grid.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;
import 'package:toolshub/features/subscription/screens/subscription_screen.dart';
import 'package:toolshub/core/navigation/app_navigator.dart';

class CategorySliverGroup extends StatelessWidget {
  const CategorySliverGroup({super.key, required this.category});
  final CategoryData category;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final isPro = auth.isPro;
    final displayTools = (isPro || category.tools.length <= 15)
        ? category.tools
        : category.tools.take(15).toList();
    final isTruncated = !isPro && category.tools.length > 15;

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
                    border: Border.all(
                        color: category.themeColor.withOpacity(0.18)),
                  ),
                  child:
                      Icon(category.icon, color: category.themeColor, size: 20),
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
                        isTruncated
                            ? 'Showing 15 of ${category.tools.length} tools'
                            : '${category.tools.length} tools',
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
          tools: displayTools,
          themeColor: category.themeColor,
        ),

        if (isTruncated)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: InkWell(
                  onTap: () => AppNavigator.toSubscription(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: category.themeColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: category.themeColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 16, color: category.themeColor),
                        const SizedBox(width: 12),
                        Text(
                          'Unlock ${category.tools.length - 15} more ${category.name} tools',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: category.themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
